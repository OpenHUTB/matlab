




classdef ZeroCrossingInfoWriter<handle
    properties(Access=private)
ModelInterfaceUtils
Writer
        ZcSignalInfos={}
    end

    methods
        function this=ZeroCrossingInfoWriter(modelInterfaceUtils,writer)
            this.ModelInterfaceUtils=modelInterfaceUtils;
            this.Writer=writer;
            this.ZcSignalInfos=this.ModelInterfaceUtils.ZcSignalInfos;
        end


        function write(this)
            this.Writer.writeLine('{');
            this.Writer.writeLine('int_T zcsIdx = 0;');



            for currentElement=1:this.ModelInterfaceUtils.ZCVectorLength
                if(this.ZcSignalInfos{currentElement}.ZcBlkRecId>=0)
                    this.writeZcSignalInfo(currentElement);
                end
            end

            this.Writer.writeLine('}');
        end
    end


    methods(Access=private)
        function writeZcSignalInfo(this,currentElement)
            zcSignalInfo=this.ZcSignalInfos{currentElement};
            this.Writer.writeLine('zcsIdx = ssCreateAndAddZcSignalInfo(S);');
            this.Writer.writeLine('ssSetZcSignalWidth(S, zcsIdx, %d);',zcSignalInfo.Width);
            this.Writer.writeLine('ssSetZcSignalName(S, zcsIdx, %s);',this.ModelInterfaceUtils.getStringLiteralCast(zcSignalInfo.Name));



            if zcSignalInfo.Width>1
                for dupIdx=1:(zcSignalInfo.Width-1)
                    this.ZcSignalInfos{currentElement+dupIdx}.ZcBlkRecId=-1;
                    this.ZcSignalInfos{currentElement+dupIdx}.ZcSignalInfoId=-1;
                end
            end

            switch zcSignalInfo.ZcSignalType
            case 'Hybrid'
                myzcstype='SL_ZCS_TYPE_HYBRID';
            case 'Continuous'
                myzcstype='SL_ZCS_TYPE_CONT';
            otherwise
                myzcstype='SL_ZCS_TYPE_DISC';
            end
            this.Writer.writeLine('ssSetZcSignalType(S, zcsIdx, %s);',myzcstype);

            if strcmp(zcSignalInfo.ZcSignalType,'Hybrid')
                for idx=1:zcSignalInfo.Width
                    this.Writer.writeLine('ssSetZcSignalIsZcElementDisc(S, zcsIdx, %d, %d);',...
                    idx-1,zcSignalInfo.IsElementDisc(idx));
                end
            end





            zcEventTypeStr=strrep(zcSignalInfo.ZcEventType,'ZC','SL_ZCS');

            this.Writer.writeLine('ssSetZcSignalZcEventType(S, zcsIdx, %s);',zcEventTypeStr);
            this.Writer.writeLine('ssSetZcSignalNeedsEventNotification(S, zcsIdx, 0);');
        end
    end
end
