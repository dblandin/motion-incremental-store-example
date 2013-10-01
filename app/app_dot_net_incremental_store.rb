class AppDotNetIncrementalStore < AFIncrementalStore
  class << self
    def type
      self.name
    end

    def model
      NSManagedObjectModel.alloc.initWithContentsOfURL(model_url)
    end

    def model_url
      NSBundle.mainBundle.URLForResource('AppDotNet', withExtension: 'xcdatamodeld')
    end
  end
end
