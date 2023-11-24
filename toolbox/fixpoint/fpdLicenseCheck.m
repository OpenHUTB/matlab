function fpdLicenseCheck()

    if~hasFixedPointDesigner()
        DAStudio.error('SimulinkFixedPoint:autoscaling:licenseCheck');
    end
end


