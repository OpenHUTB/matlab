


classdef SettingsDialog<dialogmgr.DCTableForm&dynamicprops


    properties(Access=private)
        ATNames={'UniformLinear',...
        'UniformRectangular',...
        'UniformCircular',...
        'UniformHexagonal',...
        'CircularPlanar',...
        'Concentric',...
        'Spherical',...
        'Cylindrical',...
        'ArbitraryGeometry'}
ArrayTypes
Evntl
    end

    properties(Access=public,SetObservable)

        ArrayTypeIndex=1

    end

    properties

        NumElLimit=3000
        NumElLimit3D=200

Application
    end

    methods
        function obj=SettingsDialog(SAV,name)
            if nargin<2
                name=getString(message('phased:apps:arrayapp:ArraySettings'));
            end
            if nargin<1
                SAV=[];
            end
            obj.Name=name;
            obj.Application=SAV;


            for i=1:length(obj.ATNames)
                obj.ArrayTypes{i}=phased.apps.internal.SensorArrayViewer.(['AT',obj.ATNames{i}])(obj);
            end



            obj.forceAutoApply('ArrayTypeIndex');
        end
        function initWithSystemObject(obj,varargin)
            if nargin==2


                sysObj=varargin{1};
                obj.Evntl=struct('Enabled',true);
                updateWithSystemObject(obj,sysObj);
                curAT=obj.getCurArrayType();

                curAT.save();
            end
            obj.Evntl=onPropertyChange(obj,@obj.settingsChanged);
        end
        function updateWithSystemObject(obj,sysObj)
            sensorArray=sysObj.Sensor;


            if~obj.verifySensorArray(sensorArray)
                return;
            end



            obj.Evntl.Enabled=false;
            if isa(sensorArray,'phased.ULA')
                arrIdx=1;
            elseif isa(sensorArray,'phased.URA')
                arrIdx=2;
            elseif isa(sensorArray,'phased.UCA')
                arrIdx=3;
            elseif isa(sensorArray,'phased.ConformalArray')
                arrIdx=length(obj.ATNames);
            elseif isa(sensorArray,'phased.internal.AbstractElement')


                cnf=phased.ConformalArray('Element',sensorArray,...
                'ElementPosition',[0;0;0],...
                'ElementNormal',[0;0]);
                sysObj=clone(sysObj);
                sysObj.Sensor=cnf;
                arrIdx=length(obj.ATNames);
            else

                assert(1);
            end
            obj.ArrayTypeIndex=arrIdx;
            obj.Evntl.Enabled=true;
            curAT=obj.getCurArrayType();
            updateWithArrayObj(curAT,sysObj)
        end
        function settingsChanged(obj,~,ev)


            curAT=obj.getCurArrayType();

            curAT.save();
            obj.Application.refreshGUI(ev);
        end
    end

    methods(Access=protected)
        function initTable(obj)


            c=uipopup(obj,...
            cellfun(@(c)c.TranslatedName,obj.ArrayTypes,'UniformOutput',false),...
            'label',[getString(message('phased:apps:arrayapp:ArrayType')),':']);
            c.Tag='ATDDTag';
            c.TooltipString=getString(message('phased:apps:arrayapp:ArrayTypeTT'));
            connectPropertyAndControl(obj,'ArrayTypeIndex',c,'value');

            for i=1:length(obj.ATNames)
                connectRowVisToControl(obj,['AT',obj.ATNames{i},'DlgTag'],c,i,true);
            end

            obj.mergecols(2:4);
            obj.newrow


            for i=1:4
                obj.newrow
            end
            obj.mergecols(1:5)
            c=uihline(obj);
            c.Thickness=1;
            c.ForegroundColor=[0.6,0.6,0.6];
            c.PercentWidth=100;
            c.HorizontalAlignment='center';
            obj.newrow


            pv={'DialogBorderDecoration',{...
            'TitlePanelBackgroundColorSource','Auto',...
            'TitlePanelForegroundColorSource','Custom',...
            'TitlePanelForegroundColor',[0,0,0]},...
            'DialogBorderFactory',@dialogmgr.DBInvisible};


            for i=1:length(obj.ATNames)
                dlgName=['AT',obj.ATNames{i},'Dlg'];
                addprop(obj,dlgName);
                obj.(dlgName)=uidialog(obj,dlgName,obj.ArrayTypes{i},pv{:});
                obj.(dlgName).Tag=[dlgName,'Tag'];
            end

            obj.newrow
            obj.newrow
            obj.skipcol
            obj.skipcol

            obj.addApply();

            obj.skipcol
            obj.skipcol
            obj.InterColumnSpacing=2;
            obj.InterRowSpacing=2;
            obj.InnerBorderSpacing=4;
            if ismac
                obj.ColumnWidths={140,'max',100,'max',60};
            else
                obj.ColumnWidths={140,'max',100,'max',45};
            end
            obj.HorizontalAlignment={'right','left','center','left','left'};


            for i=1:length(obj.ArrayTypes)
                obj.ArrayTypes{i}.save();
            end

        end



    end

    methods(Access=public)


        function at=getCurArrayType(obj)
            at=obj.ArrayTypes{obj.ArrayTypeIndex};
        end

    end
    methods(Static,Hidden)
        function verified=verifySensorArray(sensorArray)
            verified=false;
            try
                if~(isa(sensorArray,'phased.ULA')||...
                    isa(sensorArray,'phased.URA')||...
                    isa(sensorArray,'phased.UCA')||...
                    isa(sensorArray,'phased.ConformalArray')||...
                    isa(sensorArray,'phased.internal.AbstractElement'))

                    error(message('phased:apps:arrayapp:InvalidArray',class(sensorArray)));
                end
                if isa(sensorArray,'phased.internal.AbstractElement')
                    sensorElement=sensorArray;
                else
                    sensorElement=sensorArray.Element;
                end
                if~(isa(sensorElement,'phased.IsotropicAntennaElement')||...
                    isa(sensorElement,'phased.CosineAntennaElement')||...
                    isa(sensorElement,'phased.OmnidirectionalMicrophoneElement')||...
                    isa(sensorElement,'phased.CustomAntennaElement'))

                    error(message('phased:apps:arrayapp:InvalidElement',class(sensorElement)));
                end
                verified=true;
            catch err
                errHandle=errordlg(err.message);
                set(errHandle,'Tag','ErrorDialogTag');
            end
        end
    end
end
