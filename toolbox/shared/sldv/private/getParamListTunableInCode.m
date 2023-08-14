function paramList=getParamListTunableInCode(codeLocation)






    try
        paramList={};
        codeDescObj=coder.getCodeDescriptor(codeLocation);

        codeInterfaces=codeDescObj.getDataInterfaceTypes();


        if any(ismember(codeInterfaces,'Parameters'))
            parameterObjs=codeDescObj.getDataInterfaces('Parameters');
            for idx=1:length(parameterObjs)
                currentParamObjectType=parameterObjs(idx).Implementation.Type;
                if~rtw.connectivity.CodeInfoTypeUtils.isReadOnly(currentParamObjectType)
                    paramList{end+1}=parameterObjs(idx).GraphicalName;%#ok<AGROW> 
                end
            end
        end
    catch Mex
        if strcmp(Mex.identifier,'Simulink:Engine:ECoder_LicenseError')
            errStruct.errorMsg=getString(message('Sldv:Setup:EmbeddedCoderLicenseNotFound'));
            errStruct.identifier='Simulink:Engine:ECoder_LicenseError';
        elseif strcmp(Mex.identifier,'codedescriptor:core:BuildDirDoesNotExist')||...
            strcmp(Mex.identifier,'codedescriptor:core:CannotDetermineModelName')




            if ispc()
                codeLocation=strrep(codeLocation,'\','\\');
            end
            errStruct.errorMsg=getString(message('Sldv:Setup:CodePathNotUsableForParamAnalysis',codeLocation));
            errStruct.identifier='Sldv:Setup:CodePathNotUsableForParamAnalysis';
        else
            errStruct.identifier=Mex.identifier;
            errStruct.errorMsg=getString(message('Sldv:Setup:CodePathNotUsableForParamAnalysis',codeLocation));
        end
        mex=MException(errStruct.identifier,errStruct.errorMsg);
        throw(mex);
    end
end

