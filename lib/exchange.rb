# coding: UTF-8

require 'java'
EWS_JAR = 'EWSJavaAPI_1.2.jar'
EWS_DEPENDENCIES = %w(commons-codec-1.2.jar commons-httpclient-3.1.jar commons-logging-1.0.4.jar commons-logging-api-1.1.jar jcifs-1.3.3.jar)
(EWS_DEPENDENCIES + [EWS_JAR]).each do |jar|
  require "vendor/lib/#{jar}"
end

def microsoft
  Java::Microsoft
end

java_import microsoft.exchange.webservices.data.BasePropertySet,
            microsoft.exchange.webservices.data.EmailMessage,
            microsoft.exchange.webservices.data.EmailMessageSchema,
            microsoft.exchange.webservices.data.ExchangeService,
            microsoft.exchange.webservices.data.ExchangeVersion,
            microsoft.exchange.webservices.data.Folder,
            microsoft.exchange.webservices.data.FolderId,
            microsoft.exchange.webservices.data.FolderView,
            microsoft.exchange.webservices.data.ItemId,
            microsoft.exchange.webservices.data.ItemSchema,
            microsoft.exchange.webservices.data.ItemView,
            microsoft.exchange.webservices.data.Mailbox,
            microsoft.exchange.webservices.data.PropertyDefinitionBase,
            microsoft.exchange.webservices.data.PropertySet,
            microsoft.exchange.webservices.data.SearchFilter,
            microsoft.exchange.webservices.data.WebCredentials,
            microsoft.exchange.webservices.data.WellKnownFolderName

module Exchange
  # Public: Connects to an Exchange service specified by the given configuration.
  #
  # config - Required configuration (keys are Strings):
  #          host     - Exchange service hostname
  #          mailbox  - e.g. "as016194@cerner.com"
  #          version  - a String matching one of the ExchangeVersion enum values, e.g. "2010_sp1"
  #          domain   - authentication domain
  #          user     - Exchange username
  #          password - Exchange password
  Client = Struct.new(:config) do
    # Public: Retrieves unread emails from every folder.
    def fetch_all_unread_emails
      all_email_folders = child_folder_list(folder(WellKnownFolderName::MsgFolderRoot)).select(&method(:email_folder?))
      # TODO: may want to group by folder rather than flatten
      all_email_folders.map(&method(:fetch_unread_items)).reject(&:empty?).flatten
    end

    # Public: Retrieves details for the given email_id.
    #
    # email_id - the String Exchange ID of the EmailMessage to retrieve. Can be found with #fetch_all_unread_emails.
    def fetch_email_details(email_id)
      to_email(ItemId.new(email_id))
    end

    # Public: Retrieves up to 5,000 Items from the given Folder that are not marked as read by the service.
    #
    # Returns an Array of Item objects.
    def fetch_unread_items(folder)
      item_view = ItemView.new(10) # FIXME: 5000
      item_view.property_set = EMAIL_SUMMARY_PROPERTY_SET
      folder.find_items(SearchFilter::IsEqualTo.new(EmailMessageSchema::IsRead, false), item_view).items.to_a
    end

    # Internal: A detailed PropertySet for an EmailMessage retrieved from the ExchangeService. Defines what attributes
    # of the EmailMessage to request from the service.
    # TODO: make the caller specify what properties they want from the email rather than hard-coding this
    EMAIL_DETAIL_PROPERTY_SET = PropertySet.new(
      BasePropertySet::FirstClassProperties,
      [
        EmailMessageSchema::BccRecipients,
        EmailMessageSchema::CcRecipients,
        EmailMessageSchema::From,
        EmailMessageSchema::ReceivedBy,
        EmailMessageSchema::ReplyTo,
        EmailMessageSchema::Sender,
        EmailMessageSchema::ToRecipients,
        # TODO: do I want attachments? ItemSchema::Attachments,
        ItemSchema::Body,
        ItemSchema::DateTimeReceived,
        ItemSchema::DateTimeSent,
        ItemSchema::DisplayCc,
        ItemSchema::DisplayTo,
        ItemSchema::HasAttachments,
        ItemSchema::Importance,
        ItemSchema::InternetMessageHeaders,
        ItemSchema::IsFromMe,
        ItemSchema::Sensitivity,
        ItemSchema::Size,
        ItemSchema::Subject,
        ItemSchema::UniqueBody
      ].to_java(PropertyDefinitionBase)
    )

    # Internal: A summary PropertySet for an EmailMessage retrieved from the ExchangeService. Defines what attributes
    # of the EmailMessage to request from the service.
    EMAIL_SUMMARY_PROPERTY_SET = PropertySet.new(BasePropertySet::IdOnly, [ItemSchema::Subject].to_java(PropertyDefinitionBase))

    private

    # Internal: Recursively retrieves the descendant Folders from the given parent_folder.
    #
    # parent_folder - a Folder.
    #
    # Returns a flat sequence with the parent_folder in the first position and all descendants following.
    def child_folder_list(parent_folder)
      if parent_folder.child_folder_count == 0
        [parent_folder]
      else
        # recurse over the children to find all descendants
        children = parent_folder.find_folders(FolderView.new(parent_folder.child_folder_count)).folders
        [parent_folder] + children.map(&method(:child_folder_list)).flatten
      end
    end

    # Internal: Creates WebCredentials for use in an ExchangeService.
    def credentials
      @credentials ||= WebCredentials.new(self.config['user'], self.config['password'], self.config['domain'])
    end

    # Internal: Determines if the given Folder is an Exchange email folder.
    def email_folder?(folder)
      folder.folder_class == 'IPF.Note'
    end

    # Internal: Retrieves the Folder object from the #service with the given name.
    #
    # name - a WellKnownFolderName.
    def folder(name)
      Folder.bind(service, FolderId.new(name, Mailbox.new(self.config['mailbox'])))
    end

    # Internal: Creates an ExchangeService to request items from.
    def service
      return @service if @service
      @service = ExchangeService.new(version)
      # TODO: make this whole URI configurable
      @service.url = java.net.URI.new("https://#{self.config['host']}:443/EWS/Exchange.asmx")
      @service.credentials = credentials
      @service
    end

    # Internal: Retrieves the EmailMessage object from the given service with the given item_id.
    #
    # item_id - the ItemId of the EmailMessage to retrieve. Can be found with Folder#find_items.
    def to_email(item_id)
      EmailMessage.bind(service, item_id, EMAIL_DETAIL_PROPERTY_SET)
    end

    # Internal: Finds the ExchangeVersion enum for the given String (e.g. "2010_sp1").
    def version
      @version ||= ExchangeVersion.valueOf("Exchange#{self.config['version'].upcase}")
    end
  end
end
