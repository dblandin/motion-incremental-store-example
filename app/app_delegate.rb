class AppDelegate
  attr_reader :window, :navigation_controller

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    controller = ViewController.alloc.init
    @navigation_controller = UINavigationController.alloc.initWithRootViewController(controller)

    window.setRootViewController(navigation_controller)
    window.makeKeyAndVisible

    setup

    true
  end

  def setup
    NSPersistentStoreCoordinator.registerStoreClass(self, forStoreType: AppDotNetIncrementalStore.type)
  end

  def applicationWillTerminate(application)
    save_context
  end

  def save_context
    error = Pointer.new(:object)

    if managed_object_context.hasChanges && !managed_object_context.save(error)
      raise "Unresolved error #{error}, #{error.userInfo}"
    end
  end

  def managed_object_context
    @managed_object_context ||= begin
      NSManagedObjectContext.alloc.initWithConcurrencyType(NSMainQueueConcurrencyType).tap do |context|
        context.setPersistentStoreCoordinator(persistent_store_coordinator)
      end
    end
  end

  def managed_object_model
    @managed_object_model ||= NSManagedObjectModel.alloc.initWithContentsOfURL(model_url)
  end

  def model_url
    @model_url ||= NSBundle.mainBundle.URLForResource('AppDotNet', withExtension: 'momd')
  end

  def persistent_store_coordinator
    @persistent_store_coordinator ||= begin
      coordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(managed_object_model)

      error = Pointer.new(:object)

      unless store = coordinator.addPersistentStoreWithType(
                AppDotNetIncrementalStore.type,
                configuration: nil,
                URL: nil,
                options: nil,
                error: nil)
      end

      error = Pointer.new(:object)

      unless store.backingPersistentStoreCoordinator.addPersistentStoreWithType(
        NSSQLiteStoreType,
        configuration: nil,
        URL: store_url,
        options: store_options,
        error: error)

        raise "Unresolved error #{error}, #{error.userInfo}"
      end

      p "Store URL: #{store_url}"
      coordinator
    end
  end

  def store_options
    { NSInferMappingModelAutomaticallyOption => true,
      NSMigratePersistentStoresAutomaticallyOption => true }
  end

  def store_url
    @store_url ||= documents_directory.URLByAppendingPathComponent('AppDotNet.sqlite')
  end

  def documents_directory
    NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains: NSUserDomainMask).last
  end
end
