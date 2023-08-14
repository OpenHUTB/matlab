



classdef SpreadsheetRow<handle
    properties(Access=private)

ComSpecInfoObj
DataDictionary
ComSpecPropName
    end

    properties(Access=private,Constant=true)

        NameColumn='DataElement'
        AliveTimeoutColumn='AliveTimeout'
        HandleNeverReceivedColumn='HandleNeverReceived'
        InitValueColumn='InitValue'
        QueueLengthColumn='QueueLength';
    end

    methods
        function this=SpreadsheetRow(aComSpecInfoObj,dataDictionary)
            this.ComSpecInfoObj=aComSpecInfoObj;
            this.DataDictionary=dataDictionary;
            if autosar.api.Utils.isNvPort(aComSpecInfoObj.containerM3I)
                this.ComSpecPropName='ComSpec';
            else
                this.ComSpecPropName='comSpec';
            end
        end

        function aLabel=getDisplayLabel(this)

            if this.ComSpecInfoObj.isvalid()
                aLabel=this.ComSpecInfoObj.DataElements.Name;
            else
                aLabel='';
            end
        end

        function aIcon=getDisplayIcon(~)
            aIcon='';
        end

        function bIsValid=isValidProperty(this,aPropName)
            try
                bIsValid=any(strcmp({this.AliveTimeoutColumn,...
                this.HandleNeverReceivedColumn,this.NameColumn,...
                this.InitValueColumn,this.QueueLengthColumn},aPropName));
            catch me
                this.reportError(me);
            end
        end

        function bIsEditable=isEditableProperty(this,aPropName)
            try
                bIsEditable=false;
                switch(aPropName)
                case{this.NameColumn}
                    bIsEditable=false;
                otherwise
                    if this.ComSpecInfoObj.isvalid()&&...
                        isprop(this.getComSpecObj(),aPropName)


                        bIsEditable=true;
                    else
                        bIsEditable=false;
                    end
                end
            catch me
                this.reportError(me);
            end
        end

        function bIsReadOnly=isReadonlyProperty(this,aPropName)
            try
                bIsReadOnly=false;
                if strcmp(this.NameColumn,aPropName)

                    bIsReadOnly=true;
                else


                    if~this.ComSpecInfoObj.isvalid()||~isprop(this.getComSpecObj(),aPropName)
                        bIsReadOnly=true;
                    end
                end
            catch me
                this.reportError(me);
            end
        end

        function aPropValue=getPropValue(this,aPropName)
            try
                aPropValue='-';
                if this.ComSpecInfoObj.isvalid()
                    switch(aPropName)
                    case{this.NameColumn}
                        aPropValue=this.ComSpecInfoObj.DataElements.Name;
                    otherwise
                        if isprop(this.getComSpecObj(),aPropName)

                            aPropValue=...
                            autosar.ui.comspec.ComSpecPropertyHandler.getComSpecPropertyValueStr(...
                            this.getComSpecObj(),aPropName,this.DataDictionary);
                        end
                    end
                end
            catch me
                this.reportError(me);
            end
        end

        function setPropValue(this,aPropName,aPropValue)
            try

                autosar.ui.comspec.ComSpecPropertyHandler.setComSpecPropertyValue(...
                this.getComSpecObj(),aPropName,aPropValue);
            catch me
                this.reportError(me);
            end
        end

        function aPropType=getPropDataType(~,aPropName)
            aPropType=autosar.ui.comspec.ComSpecPropertyHandler.getComSpecPropertyDataType(aPropName);
            if strcmp(aPropType,'enum')




                aPropType='bool';
            end
        end

    end

    methods(Access=private)
        function reportError(~,me)
            errordlg(me.message,...
            autosar.ui.metamodel.PackageString.ErrorTitle,'replace')
        end

        function comSpecObj=getComSpecObj(this)
            comSpecObj=this.ComSpecInfoObj.(this.ComSpecPropName);
        end
    end

end



