function output=isZynqSupportPackageInstalled()








    output=isequal(exist('zynq.setup.ZynqFirmwareUpdate','class'),8);
end
