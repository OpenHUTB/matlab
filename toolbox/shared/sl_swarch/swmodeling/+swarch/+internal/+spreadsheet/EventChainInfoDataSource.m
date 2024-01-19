classdef EventChainInfoDataSource<handle

    properties(Constant)
        EventChainNameCol=getString(message('SoftwareArchitecture:ArchEditor:EventChainNameColumn'));
        EventChainDurationCol=getString(message('SoftwareArchitecture:ArchEditor:EventChainDurationColumn'));
    end


    properties(Access=private)
pEventChain
pParent
pChildren
pMimeData
    end


    methods
        function this=EventChainInfoDataSource(parentTab,ecObj)
            this.pEventChain=ecObj;
            this.pParent=parentTab;

            columns=[...
            this.EventChainNameCol,'<*>'...
            ,this.EventChainDurationCol...
            ];
            kvPairsList=GLEE.ByteArrayList;
            pair1=GLEE.ByteArrayPair(...
            GLEE.ByteArray(columns),...
            GLEE.ByteArray('internal.swarch.EventChainInfoDataSource'));
            kvPairsList.add(pair1);
            this.pMimeData=kvPairsList;
        end


        function ref=makeReference(this,parentEC)
            ref=swarch.internal.spreadsheet.EventChainRefDataSource(...
            this.pParent,parentEC,this,false);
        end


        function tObj=get(this)
            tObj=this.pEventChain;
        end


        function propValue=getPropValue(this,propName)
            switch propName
            case this.EventChainDurationCol
                t=this.pEventChain.duration.timeValue;
                t=t*power(10,-double(this.pEventChain.duration.unit));
                propValue=num2str(t);
            case this.EventChainNameCol
                propValue=this.pEventChain.getName();
            otherwise
                propValue={};
            end
        end


        function setPropValue(this,propName,propValue)
            switch propName
            case this.EventChainDurationCol
                ownerArch=this.pEventChain.parent.p_Architecture;
                mdl=mf.zero.getModel(ownerArch);
                t=str2double(propValue);
                timeNanoSec=t*1e9;
                unit=systemcomposer.architecture.model.traits.TimingConstraintUnit.UNIT_1NS;
                this.pEventChain.duration=systemcomposer.architecture.model.traits.TimingConstraint.createTimingConstraint(mdl,timeNanoSec,unit);
            case this.EventChainNameCol
                this.pEventChain.setName(propValue);
            end
        end


        function isValid=isValidProperty(~,~)
            isValid=true;
        end


        function isEditable=isEditableProperty(this,propName)
            switch propName
            case this.EventChainDurationCol
                isEditable=true;
            case this.EventChainNameCol
                isEditable=true;
            otherwise
                isEditable=false;
            end
        end


        function isHyperlink=propertyHyperlink(~,~,~)
            isHyperlink=false;
        end


        function tf=isHierarchical(~)
            tf=true;
        end


        function children=getHierarchicalChildren(this)
            children=this.pChildren;
        end


        function children=getChildren(this)
            children=this.pChildren;
        end


        function isAllowed=isDragAllowed(~)
            isAllowed=false;
        end


        function isAllowed=isDropAllowed(~)
            isAllowed=false;
        end


        function schema=getPropertySchema(this)
            schema=swarch.internal.propertyinspector.EventChainSchema(...
            this.pParent.getSpreadsheet().getStudio(),this.pEventChain);
        end


        function allowed=performDrag(~,~)
            allowed=false;
        end


        function allowed=performDrop(~,~)
            allowed=false;
        end


        function data=getMimeData(this)
            data=this.pMimeData;
        end


        function mimeType=getMimeType(~)
            mimeType='application/swarch-mimetype';
        end


        function addChildElement(this,dataSource)
            this.pChildren=[this.pChildren,dataSource];
        end


        function tf=isEventChainReference(~)
            tf=false;
        end
    end
end


