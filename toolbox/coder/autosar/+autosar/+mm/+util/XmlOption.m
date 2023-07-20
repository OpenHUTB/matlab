



classdef XmlOption<handle



    properties(Constant,Access=public)
        Enumeration='Enumeration';
        String='String';
        Double='Double';
        Logical='Logical';
    end

    properties
        name;
        type;
        allowedValues;
        defaultValue;
        customVerifyFcns;
        visibility autosar.mm.util.XmlOptionVisibilityEnum=autosar.mm.util.XmlOptionVisibilityEnum.All;
        isPackage;
    end

    methods
        function obj=XmlOption(name,type,verifyFcns,allowedValues,defaultValue,visibility,isPackage)
            assert(islogical(isPackage),'invalid isPackage argument');

            obj.name=name;
            obj.type=type;
            obj.customVerifyFcns=verifyFcns;
            obj.allowedValues=allowedValues;
            obj.defaultValue=defaultValue;
            obj.visibility=visibility;
            obj.isPackage=isPackage;
        end

        function vals=getAllowedValues(this)
            vals=this.allowedValues;
        end

        function vals=getDefaultValue(this)
            vals=this.defaultValue;
        end

        function type=getType(this)
            type=this.type;
        end

        function visibility=getVisibility(this)
            visibility=this.visibility;
        end

        function verify(this,newValue,curValue,m3iModel)


            import autosar.mm.util.XmlOption;
            if strcmp(this.type,XmlOption.Enumeration)
                this.verifyValidEnum(newValue)
            elseif strcmp(this.type,XmlOption.Logical)
                this.verifyValidLogical(newValue,this.name)
            end

            for v=this.customVerifyFcns
                v{1}(newValue,curValue,m3iModel,this.name);
            end
        end

    end

    methods(Access=private)
        function verifyValidEnum(this,newValue)

            import autosar.mm.util.XmlOption
            invalidValues=setdiff(newValue,this.allowedValues);
            if~isempty(invalidValues)
                DAStudio.error('RTW:autosar:apiInvalidPropertyValue',...
                newValue,this.name,...
                XmlOption.cell2str(this.allowedValues));
            end
        end
    end

    methods(Static,Access=public)

        function verifyXmlOptionsPackage(newValue,curValue,m3iModel,propName)
            import autosar.api.Utils;

            errArgs=Utils.verifyXmlOptionsPackage(...
            m3iModel,curValue,newValue,propName);
            if~isempty(errArgs{1})
                DAStudio.error(errArgs{:});
            end
        end

        function verifyXmlOptionsQualifiedName(newQualifiedName,~,m3iModel,~)
            maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(m3iModel);
            idType='absPathShortName';

            [isValid,errmsg,errId]=autosarcore.checkIdentifier(newQualifiedName,idType,maxShortNameLength);
            if~isValid
                exception=MSLException([],errId,'%s',errmsg);
                throwAsCaller(exception);
            end
        end

        function verifyValidLogical(newValue,propName)
            if~islogical(newValue)||isnan(newValue)||...
                isinf(newValue)
                DAStudio.error('RTW:autosar:apiInvalidPropertyValue',...
                num2str(newValue),propName,...
                '''true, false''');
            end
        end
    end


    methods(Static,Access=private)
        function str=cell2str(cellArray)

            str='';
            sep='';
            for ii=1:length(cellArray)
                str=sprintf('%s%s''%s''',str,sep,cellArray{ii});
                sep=', ';
            end
            str=sprintf('%s',str);
        end

    end
end
