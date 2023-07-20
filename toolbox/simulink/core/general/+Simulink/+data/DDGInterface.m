classdef(Abstract)DDGInterface<handle















    methods(Hidden)























        function retVal=getPropDataType(obj,propName)%#ok










            retVal='MATLAB array';
        end


        function retVal=getPropAllowedValues(obj,propName)%#ok

            retVal={};
        end
    end


    methods(Hidden)





        function proxyObj=getDialogProxy(obj)
            proxyObj=obj;
        end


        function forwardedObj=getForwardedObject(obj)
            forwardedObj=obj;
        end


        function retVal=getDisplayClass(obj)
            retVal=class(obj);
        end


        function retVal=getDisplayLabel(obj)
            if isValidProperty(obj,'Name')
                retVal=obj.Name;%#ok
            else
                retVal=getDisplayClass(obj);
            end
        end


        function retVal=getFullName(obj)
            retVal=getDisplayLabel(obj);
        end


        function retVal=getPropValue(obj,propName)
            try
                try
                    propVal=obj.(propName);
                catch E %#ok

                    propVal=eval(['obj.',propName]);
                end

                switch getPropDataType(obj,propName)
                case{'ustring','string','enum','asciiString'}
                    retVal=propVal;
                case 'bool'
                    if propVal
                        retVal='1';
                    else
                        retVal='0';
                    end
                otherwise
                    if isstring(propVal)
                        retVal=DAStudio.MxStringConversion.convertToString(propVal);
                    elseif isobject(propVal)

                        if(isscalar(propVal)&&Simulink.data.isSupportedEnumObject(propVal))
                            retVal=[class(propVal),'.',char(propVal)];
                        else
                            retVal=l_GetSizeClassString(propVal);
                        end
                    elseif isnumeric(propVal)||islogical(propVal)
                        if isempty(propVal)
                            retVal='[ ]';
                        elseif length(size(propVal))==2
                            retVal=l_GetNumericString(propVal);
                        else
                            retVal=l_GetSizeClassString(propVal);
                        end
                    elseif ischar(propVal)

                        retVal=strrep(propVal,'''','''''');
                        retVal=sprintf('''%s''',retVal);
                    else
                        retVal=l_GetSizeClassString(propVal);
                    end
                end
            catch E %#ok
                retVal='';
            end
        end


    end

end


function retVal=l_GetNumericString(propVal)


    if isa(propVal,'double')



        retVal=mat2str(propVal,17);
    elseif isa(propVal,'single')



        retVal=mat2str(propVal,10);
    else
        retVal=mat2str(propVal);
    end

    if size(propVal,1)>1

        retVal=retVal';
        retVal(end+1,:)=';';
        retVal(end+1,:)=' ';
        retVal=retVal(1:end-2);
        retVal=retVal';
    end


    while~isempty(strfind(retVal,'  '))
        retVal=strrep(retVal,'  ',' ');
    end


    if(~isa(propVal,'double')&&...
        ~islogical(propVal))
        retVal=[class(propVal),'(',retVal,')'];
    end


    if(length(retVal)>100)
        retVal=l_GetSizeClassString(propVal);
    end
end


function retVal=l_GetSizeClassString(propVal)

    dims=size(propVal);
    dimsStr=num2str(dims(1));
    for idx=2:length(dims)
        dimsStr=[dimsStr,'x',num2str(dims(idx))];%#ok
    end
    retVal=sprintf('<%s %s>',dimsStr,class(propVal));
end



