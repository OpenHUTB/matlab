


classdef ATUniformRectangular<phased.apps.internal.SensorArrayViewer.ArrayType

    properties(SetObservable)
        Size=[4,4]
        ElemSpacing=[0.5,0.5]
        ElemSpacingUnitsIndex=1
        LatticeIndex=1
        RowTaperTypeIndex=1
        RowSidelobeAttenuation=30
        RowNbar=4
        RowBeta=0.5
        RowCustomTaper=1
        ColTaperTypeIndex=1
        ColSidelobeAttenuation=30
        ColNbar=4
        ColBeta=0.5
        ColCustomTaper=1
        CustomTaper=1
        ArrayNormal='x'
    end
    properties
        isTaperRowCol=true;
    end
    properties(SetAccess=private)
        TranslatedName=getString(message('phased:apps:arrayapp:ura'));
        ShortName='URA'
        pElRatio=1
    end

    properties(Access=private)
LatticeNames
MsgLatticeNames
    end

    methods
        function obj=ATUniformRectangular(dlg)

            obj.ArrayObj=phased.URA();
            obj.CanPlotGratingLobe=true;

            if nargin<1
                return
            end

            obj.Application=dlg.Application;

            obj.LatticeNames={'Rectangular','Triangular'};
            obj.MsgLatticeNames={getString(message('phased:apps:arrayapp:Rectangular')),...
            getString(message('phased:apps:arrayapp:Triangular'))};
        end

        function tt=getCurTaperType(obj)
            if~obj.isTaperRowCol
                tt=getCurTaperType@phased.apps.internal.SensorArrayViewer.ArrayType(obj);
                return
            end

            tt=phased.apps.internal.SensorArrayViewer.TaperType.getTaperAtPos(obj.RowTaperTypeIndex);
        end
        function updateWithArrayObj(obj,sysObj)
            sensorArray=sysObj.Sensor;
            latticeIndex=find(strcmp(sensorArray.Lattice,obj.LatticeNames));

            pvPair={'Size',sensorArray.Size,...
            'ElemSpacing',sensorArray.ElementSpacing,...
            'LatticeIndex',latticeIndex,...
            'ArrayNormal',sensorArray.ArrayNormal};
            updateWithArrayObj@phased.apps.internal.SensorArrayViewer.ArrayType(obj,sysObj,pvPair);
        end

    end

    methods(Access=protected)

        function updateArrayObj(obj)

            ratio=1;
            if obj.ElemSpacingUnitsIndex~=1
                ratio=obj.PropSpeed/obj.SignalFreqs(1);
            end
            obj.pElRatio=ratio;
            set(obj.ArrayObj,'Size',obj.Size);
            set(obj.ArrayObj,'ElementSpacing',obj.ElemSpacing*ratio);
            lattice=obj.LatticeNames{obj.LatticeIndex};
            set(obj.ArrayObj,'Lattice',lattice);
            set(obj.ArrayObj,'ArrayNormal',obj.ArrayNormal);

            obj.expandRangeForFreq();
            el=obj.getCurElementType();
            obj.ArrayObj.Element=el.getElement(obj);

        end

        function as=getArraySizeWithoutSave(~,pending)
            as=pending.Size(1)*pending.Size(2);
        end
        function taperPV=getPVTapers(obj,sensorArray)

            obj.isTaperRowCol=false;
            taperPV=getPVTapers@phased.apps.internal.SensorArrayViewer.ArrayType(obj,sensorArray);
        end
    end

    methods(Access=protected)

        function initTable(obj)

            initTable@phased.apps.internal.SensorArrayViewer.ArrayType(obj);


            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:Size')),':']);
            c.Tag=[obj.ShortName,'_SizeTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:SizeTT'));
            c.ValidAttributes={'real','row','numel',2,'>',1,'finite','integer','nonempty','nonnan'};
            connectPropertyAndControl(obj,'Size',c);
            obj.newrow;


            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:ElementSpacing')),':']);
            c.Tag=[obj.ShortName,'_ElemSpacingTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:ElementSpacingRTT'));
            c.ValidAttributes={'real','row','numel',2,'positive','finite','nonempty','nonnan'};
            connectPropertyAndControl(obj,'ElemSpacing',c);

            c=uipopup(obj,{getString(message('phased:apps:arrayapp:meter')),getString(message('phased:apps:arrayapp:Lambda'))});
            c.Tag=[obj.ShortName,'_ElemSpacingUnitsTag'];
            connectPropertyAndControl(obj,'ElemSpacingUnitsIndex',c,'value');
            obj.newrow;


            obj.addSignalFrequenciesControl();


            c=uipopup(obj,obj.MsgLatticeNames,'label',[getString(message('phased:apps:arrayapp:Lattice')),':']);
            c.TooltipString=getString(message('phased:apps:arrayapp:LatticeTT'));
            c.Tag=[obj.ShortName,'_LatticeDDTag'];
            connectPropertyAndControl(obj,'LatticeIndex',c,'value');
            obj.newrow;


            c=uipopup(obj,{getString(message('phased:apps:arrayapp:xaxis')),...
            getString(message('phased:apps:arrayapp:yaxis')),...
            getString(message('phased:apps:arrayapp:zaxis'))},...
            'label',[getString(message('phased:apps:arrayapp:ArrayNormal')),':']);
            c.Tag=[obj.ShortName,'_ArrayNormalTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:ArrayNormalTT'));
            connectPropertyAndControl(obj,'ArrayNormal',c);
            obj.newrow;


            obj.addPropSpeedControl();
            obj.addSteeringControl();
            obj.addTaperDropdown('Row','Row');
            obj.addTaperDropdown('Col','Column');



            c=uieditv(obj);
            c.Tag=[obj.ShortName,'_CustomTaperTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:CustomTaperTT'));
            c.ValidAttributes={'finite','nonnan','nonempty','2d'};
            connectPropertyAndControl(obj,'CustomTaper',c);

            c.UserData='';
            connectRowVisToControl(obj,c.Tag,c,'nan',true);
            obj.newrow;
        end
    end

    methods
        function verifyParameters(obj,pending,~)

            verifyParameters@phased.apps.internal.SensorArrayViewer.ArrayType(obj,pending);


            SigFreqs=pending.SignalFreqs;
            usingLambda=pending.ElemSpacingUnitsIndex~=1;

            if~isscalar(SigFreqs)&&usingLambda
                e=MException('SensorArray:InvalidWavelength','Signal Frequencies must be scalar when using wavelength units');
                throwAsCaller(e);
            end


        end

        function verifyCustomTaper(obj,pending,ev)
            if~obj.isTaperRowCol
                verifyCustomTaper@phased.apps.internal.SensorArrayViewer.ArrayType(obj,pending,ev);
                return
            end
            numRows=pending.Size(1);
            numCols=pending.Size(2);


            curRowTT=phased.apps.internal.SensorArrayViewer.TaperType.getTaperAtPos(pending.RowTaperTypeIndex);
            isCustomTaper=curRowTT==phased.apps.internal.SensorArrayViewer.TaperType.Custom;
            customTaper=pending.RowCustomTaper;
            if isCustomTaper&&~isscalar(customTaper)&&length(customTaper)~=numCols
                e=MException('SensorArray:InvalidDimensions',['Expected Row Custom Taper to be scalar or have ',num2str(pending.Size(2)),' elements']);
                throwAsCaller(e);
            end


            curColTT=phased.apps.internal.SensorArrayViewer.TaperType.getTaperAtPos(pending.ColTaperTypeIndex);
            isCustomTaper=curColTT==phased.apps.internal.SensorArrayViewer.TaperType.Custom;
            customTaper=pending.ColCustomTaper;
            if isCustomTaper&&~isscalar(customTaper)&&length(customTaper)~=numRows
                e=MException('SensorArray:InvalidDimensions',['Expected Column Custom Taper to be scalar or have ',num2str(pending.Size(1)),' elements']);
                throwAsCaller(e);
            end
        end
    end

    methods
        function genCode(obj,mcode)

            lattice=obj.LatticeNames{obj.LatticeIndex};

            mcode.addcr('% Create a uniform rectangular array');
            mcode.addcr('h = phased.URA;');
            mcode.addcr(['h.Size = ',mat2str(obj.Size),';']);
            mcode.addcr(['h.ElementSpacing = ',mat2str(obj.ElemSpacing*obj.pElRatio),';']);
            mcode.addcr(['h.Lattice = ''',lattice,''';']);
            mcode.addcr(['h.ArrayNormal = ''',obj.ArrayNormal,''';']);
        end

        function genCodeTaper(obj,mcode)

            if~obj.isTaperRowCol
                genCodeTaper@phased.apps.internal.SensorArrayViewer.ArrayType(obj,mcode);
                return;
            end

            rowTaper=phased.apps.internal.SensorArrayViewer.TaperType.getTaperAtPos(obj.RowTaperTypeIndex);
            mcode.addcr('%Calculate Row Taper');
            rowTaper.genCode(mcode,'rwind',...
            obj.Size(2),...
            obj.RowSidelobeAttenuation,...
            obj.RowBeta,...
            obj.RowNbar,...
            obj.RowCustomTaper,...
            obj.StringValues.RowCustomTaper);
            mcode.addcr(['rwind = repmat(rwind,',num2str(obj.Size(1)),',1);']);


            colTaper=phased.apps.internal.SensorArrayViewer.TaperType.getTaperAtPos(obj.ColTaperTypeIndex);
            mcode.addcr('%Calculate Column Taper');
            colTaper.genCode(mcode,'cwind',...
            obj.Size(1),...
            obj.ColSidelobeAttenuation,...
            obj.ColBeta,...
            obj.ColNbar,...
            obj.ColCustomTaper,...
            obj.StringValues.ColCustomTaper);
            mcode.addcr(['cwind = repmat(cwind.'',1,',num2str(obj.Size(2)),');']);

            mcode.addcr('%Calculate taper');
            mcode.addcr('wind = rwind.*cwind;');
            mcode.addcr('h.Taper = wind;');

        end
    end

end

