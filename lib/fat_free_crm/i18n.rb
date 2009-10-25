module FatFreeCRM
  module I18n

    #----------------------------------------------------------------------------
    def t(*args)
      if args.size == 1 || args.second.is_a?(Hash)
        super(*args)
      elsif args.second.is_a?(Fixnum)
        super(args.first, :count => args.second)
      else
        super(args.first, :value => args.second)
      end
    end

    # Scan config/locales directory for Fat Free CRM localization files
    # (i.e. *_fat_free_crm.yml) and return locale part of the file name.
    #----------------------------------------------------------------------------
    def locales
      @@locales ||= Dir.entries(RAILS_ROOT + "/config/locales").grep(/_fat_free_crm\.yml$/) { |f| f.sub("_fat_free_crm.yml", "") }
    end

    # Return a hash where the key is locale name, and the value is language name
    # as defined in the locale_fat_free_crm.yml file.
    #----------------------------------------------------------------------------
    def languages
      @@languages ||= locales.inject({}) do |hash, locale|
        hash[locale] = t(:language, :locale => locale)
        hash
      end
    end

  end
end
