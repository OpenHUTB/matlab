function[parentDir,pkgName]=ssc_screeninput(command,varargin)

















    [pkgName,parentDir]=ssc_package_info(command,varargin{:});
    ssc_validate_package(command,pkgName,parentDir);

end