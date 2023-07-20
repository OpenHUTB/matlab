function DrivingReplacements(obj)




    if isR2018bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('drivingscenarioandsensors/Scenario Reader');
    end

    if isR2017aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('drivinglib/Radar Detection Generator');
        obj.removeLibraryLinksTo('drivinglib/Vision Detection Generator');
        obj.removeLibraryLinksTo('drivinglib/Multi-Object Tracker');
    end

