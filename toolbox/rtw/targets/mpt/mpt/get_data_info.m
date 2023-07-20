function propValue=get_data_info(objName,property,varargin)































































    try
        propValue=[];

        if evalin('base',['exist(''',objName,''',''var'');'])==1
            obj=evalin('base',objName);
            if~isa(obj,'Simulink.Data')
                MSLDiagnostic('RTW:mpt:GetDataInforMsg1',objName).reportAsWarning;
                return;
            end
        else
            MSLDiagnostic('RTW:mpt:GetDataInforMsg2',objName).reportAsWarning;
            return;
        end

        if strcmpi(property,'cscdefn')&&~isempty(varargin)

            packageName=varargin{1};
            propValue=processcsc('GetCSCDefns',packageName);
        elseif strcmpi(property,'memorysectiondefn')&&~isempty(varargin)

            packageName=varargin{1};
            propValue=processcsc('GetMemorySectionDefns',packageName);
        elseif strcmpi(property,'all')

            propValue=obj;
        else

            CoderInfo=obj.CoderInfo;
            if(isprop(obj,property)&&...
                ~strcmp(property,'StorageClass'))


                propValue=obj.(property);
            elseif isprop(CoderInfo,property)

                propValue=CoderInfo.(property);
            else
                if isprop(CoderInfo,'CustomAttributes')

                    cusAttri=CoderInfo.CustomAttributes;
                    if~isempty(cusAttri)&&isprop(cusAttri,property)
                        propValue=cusAttri.(property);
                    else
                        MSLDiagnostic('RTW:mpt:GetDataInforMsg3',property).reportAsWarning;
                    end
                else
                    MSLDiagnostic('RTW:mpt:GetDataInforMsg3',property).reportAsWarning;
                end
            end
        end
    catch merr
        propValue=[];
        MSLDiagnostic('RTW:mpt:GetDataInforMsg4',property,merr.message).reportAsWarning;
    end

end

