classdef(Sealed=true)PreferencesSettings<realtime.Info






    properties(SetAccess='private')
    end

    properties(Constant)
    end


    methods
        function h=PreferencesSettings(filePathName,hardwareName,varargin)
            h.deserialize(filePathName,hardwareName,varargin);
        end

        function set(h,field,value)
            h.Data.(field)=value;
        end

        function value=get(h,field)
            value=h.Data.(field);
        end

        function hObj=expand(h,hObj)
            propList=properties(hObj);
            for i=1:length(propList)
                prop=propList{i};
                if~ischar(hObj.get(prop))||isempty(hObj.get(prop))
                    continue
                end
                if iscell(prop)
                    for j=1:length(prop)
                        hObj.set(prop{j},h.replaceToken(hObj.(prop{j})));
                    end
                else
                    hObj.set(prop,h.replaceToken(hObj.(prop)));
                end
            end
        end

    end


    methods(Access='private')
        function str=replaceToken(h,str)
            while(1)
                [tokens,~]=regexp(str,'\$\(([a-zA-Z_][\w_]*)\)','tokens','tokenExtents');
                if isempty(tokens)
                    break;
                else
                    for i=1:length(tokens)
                        token=tokens{i}{1};
                        try
                            value=h.get(token);
                            str=strrep(str,['$(',token,')'],value);
                        catch

                        end
                    end
                end;
            end
        end
    end
end
