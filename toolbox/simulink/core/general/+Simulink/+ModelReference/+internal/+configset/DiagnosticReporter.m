classdef DiagnosticReporter<Simulink.ModelReference.internal.configset.ParentChildMismatchReporter







    properties(Access=private)
MyComparator
MyError
MyParentOrigCS
    end


    methods

        function this=DiagnosticReporter()
            resetProperties(this);
        end


        function result=report(obj,varargin)

            params=obj.MyComparator.getMismatchedParams();

            if isempty(params)
                result=[];
                return;
            end


            obj.MyParentOrigCS=varargin{1};


            obj.MyError.identifier='Simulink:slbuild:topChildMdlParamMismatch';
            obj.MyError.message=DAStudio.message(obj.MyError.identifier,...
            obj.MyComparator.getParentName(),obj.MyComparator.getChildName());


            cellfun(@(x)(obj.createErrorMessage(x)),params);

            result=obj.MyError;
            error(result);
        end


        function setComparator(obj,aComparator)
            obj.MyComparator=aComparator;
        end
    end


    methods(Access=private)

        function resetProperties(obj)
            obj.MyComparator=[];
            obj.MyError=[];
            obj.MyParentOrigCS=[];
        end


        function createErrorMessage(obj,param)

            [parentValue,childValue]=obj.getStringValues(param);



            if strcmp(param,'EvaledLifeSpan')
                param='LifeSpan';
            end


            layout=configset.internal.getConfigSetCategoryLayout();
            configSet=obj.MyComparator.getParentCS();
            if layout.isUIParam(param,configSet)

                paramInfo=configset.getParameterInfo(configSet,param);

                promptText=regexprep(paramInfo.getDescription(),':','');


                identifier='Simulink:slbuild:topChildMdlParamMismatchMsgUI';
                msg=DAStudio.message(identifier,...
                promptText,obj.getParamText(param),...
                obj.MyComparator.getParentName(),param,parentValue,...
                obj.MyComparator.getChildName(),param,childValue);
            else

                identifier='Simulink:slbuild:topChildMdlParamMismatchMsgNonUI';
                msg=DAStudio.message(identifier,param,parentValue,childValue);
            end

            obj.MyError.message=[obj.MyError.message,msg];
        end



        function paramText=getParamText(~,param)
            if strcmp(param,'PurelyIntegerCode')
                paramText=['~',param];
            else
                paramText=param;
            end
        end


        function[parent,child]=getStringValues(obj,param)




            if strcmp(param,'CodeInterfacePackaging')
                parentValue=get_param(obj.MyParentOrigCS,param);
            else
                parentValue=get_param(obj.MyComparator.getParentCS(),param);
            end
            childValue=get_param(obj.MyComparator.getChildCS(),param);

            parent=obj.convertValueToString(parentValue);
            child=obj.convertValueToString(childValue);
        end


        function strValue=convertValueToString(obj,value)
            strValue='-empty-';
            if~isempty(value)
                if ischar(value)||isnumeric(value)
                    strValue=num2str(value);
                elseif iscell(value)
                    if iscellstr(value)&&length(value)==1
                        strValue=strcat('{''',value{1},'''}');
                    else
                        strValue=strcat('{',obj.getFormattedDims(value),' cell}');
                    end
                elseif isstruct(value)
                    strValue=strcat('[',obj.getFormattedDims(value),' struct]');
                end
            end
        end


        function str=getFormattedDims(~,value)
            str=num2str(size(value,1));
            d=ndims(value);
            for i=2:d
                str=strcat(str,'x',num2str(size(value,i)));
            end
        end

    end

end


