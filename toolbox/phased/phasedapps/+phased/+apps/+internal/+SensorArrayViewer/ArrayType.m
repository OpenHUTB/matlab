


classdef(Abstract)ArrayType<dialogmgr.DCTableForm



    properties(SetObservable)
        ElementTypeIndex=1
        FrequencyVector=[0,1e20]
        FrequencyResponse=[0,0]
        AzimuthAngles=-180:180
        ElevationAngles=-90:90
        MagnitudePattern=zeros(181,361)
        PhasePattern=zeros(181,361)
        IsBackBaffled=false
        CosinePower=[1,1]
        SignalFreqs=3e8
        PropSpeed=3e8
        SteeringIsOn=false
        SteeringAngles=[0;0]
        PhaseShiftBits=0;
    end

    properties(Access=public)

Elements
Tapers

SteerWeights
        TaperWeights=1
        FreqRange=[0,1e20]

CanPlotGratingLobe

ArrayObj
Application
    end

    properties(Abstract,SetAccess=private)
TranslatedName
ShortName
    end

    methods

        function save(obj)
            obj.updateArrayObj();
            tt=obj.getCurTaperType();
            [obj.TaperWeights,obj.SteerWeights]=tt.computeWindow(obj);
            set(obj.ArrayObj,'Taper',obj.TaperWeights);
        end


        function et=getCurElementType(obj)
            et=phased.apps.internal.SensorArrayViewer.ElementType.getElementAtPos(obj.ElementTypeIndex);
        end

        function res=getArraySize(obj)
            res=getNumElements(obj.ArrayObj);
        end

        function tt=getCurTaperType(~)
            tt=phased.apps.internal.SensorArrayViewer.TaperType.Custom;
        end
        function updateWithArrayObj(obj,sysObj,pvPairs)

            sensorElement=sysObj.Sensor.Element;
            pvElPairs={};
            if isa(sensorElement,'phased.IsotropicAntennaElement')
                pvElPairs={'ElementTypeIndex',1,...
                'IsBackBaffled',sensorElement.BackBaffled};
            elseif isa(sensorElement,'phased.CosineAntennaElement')
                pvElPairs={'ElementTypeIndex',2,...
                'CosinePower',sensorElement.CosinePower};
            elseif isa(sensorElement,'phased.OmnidirectionalMicrophoneElement')
                pvElPairs={'ElementTypeIndex',3,...
                'IsBackBaffled',sensorElement.BackBaffled};
            elseif isa(sensorElement,'phased.CustomAntennaElement')
                pvElPairs={'ElementTypeIndex',5,...
                'FrequencyVector',sensorElement.FrequencyVector,...
                'FrequencyResponse',sensorElement.FrequencyResponse,...
                'AzimuthAngles',sensorElement.AzimuthAngles,...
                'ElevationAngles',sensorElement.ElevationAngles,...
                'MagnitudePattern',sensorElement.MagnitudePattern,...
                'PhasePattern',sensorElement.PhasePattern};
            else
                assert(1);
            end

            taperPairs=getPVTapers(obj,sysObj.Sensor);
            setProperties(obj,pvPairs{:},pvElPairs{:},taperPairs{:},...
            'SignalFreqs',sysObj.OperatingFrequency,...
            'PropSpeed',sysObj.PropagationSpeed);
        end
    end

    methods(Access=protected)
        function taperPV=getPVTapers(~,sensorArray)
            taper=sensorArray.Taper;
            taperPV={};
            if~isscalar(taper)||taper~=1
                taperPV={'CustomTaper',taper};
            end
        end
        function initTable(obj)


            obj.addValidationFunction(@obj.verifyParameters);
            obj.addValidationFunction(@obj.verifyCustomTaper);
            obj.addValidationFunction(@obj.validateElLimit);

            obj.InterColumnSpacing=2;
            obj.InterRowSpacing=2;
            obj.InnerBorderSpacing=0;

            if ismac

                obj.ColumnWidths={140,'max',60};
            else
                obj.ColumnWidths={140,'max',45};
            end
            obj.HorizontalAlignment={'right','left','left'};


            c=uipopup(obj,phased.apps.internal.SensorArrayViewer.ElementType.names(),...
            'label',[getString(message('phased:apps:arrayapp:Element')),':']);
            c.Tag=[obj.ShortName,'_ElementTypeDDTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:ElementTT'));
            connectRowVisToControl(obj,[obj.ShortName,'_BackBaffledTag'],c,{phased.apps.internal.SensorArrayViewer.ElementType.CosineAntenna.Name,...
            phased.apps.internal.SensorArrayViewer.ElementType.CardioidMicrophone.Name,...
            phased.apps.internal.SensorArrayViewer.ElementType.CustomAntenna.Name},false);
            connectRowVisToControl(obj,[obj.ShortName,'_CosinePowerTag'],c,phased.apps.internal.SensorArrayViewer.ElementType.CosineAntenna.ID,true);
            connectRowVisToControl(obj,{[obj.ShortName,'_FreqVectorTag'],[obj.ShortName,'_FreqResponseTag'],[obj.ShortName,'_AzAnglesTag'],...
            [obj.ShortName,'_ElAnglesTag'],[obj.ShortName,'_MagnitudePatternTag'],[obj.ShortName,'_PhasePatternTag']},...
            c,phased.apps.internal.SensorArrayViewer.ElementType.CustomAntenna.ID,true);
            connectPropertyAndControl(obj,'ElementTypeIndex',c,'value');
            obj.newrow


            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:FrequencyVector')),':']);
            c.Tag=[obj.ShortName,'_FreqVectorTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:FrequencyVectorTT'));
            c.ValidAttributes={'nonempty','finite','row','nonnegative'};
            uitext(obj,getString(message('phased:apps:arrayapp:Hz')));
            connectPropertyAndControl(obj,'FrequencyVector',c);
            obj.newrow;


            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:FrequencyResponse')),':']);
            c.Tag=[obj.ShortName,'_FreqResponseTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:FrequencyResponseTT'));
            c.ValidAttributes={'real','row','nonnan'};
            uitext(obj,getString(message('phased:apps:arrayapp:dB')));
            connectPropertyAndControl(obj,'FrequencyResponse',c);
            obj.newrow;





            c=uieditv(obj,'-180:180','label',[getString(message('phased:apps:arrayapp:AzimuthAngles')),':']);
            c.Tag=[obj.ShortName,'_AzAnglesTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:AzimuthAnglesTT'));
            c.ValidAttributes={'row','>=',-180,'<=',180};
            uitext(obj,getString(message('phased:apps:arrayapp:degrees')));
            connectPropertyAndControl(obj,'AzimuthAngles',c);
            obj.newrow;


            c=uieditv(obj,'-90:90','label',[getString(message('phased:apps:arrayapp:ElevationAngles')),':']);
            c.Tag=[obj.ShortName,'_ElAnglesTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:ElevationAnglesTT'));
            c.ValidAttributes={'row','>=',-90,'<=',90};
            uitext(obj,getString(message('phased:apps:arrayapp:degrees')));
            connectPropertyAndControl(obj,'ElevationAngles',c);
            obj.newrow;


            c=uieditv(obj,'zeros(181,361)','label',[getString(message('phased:apps:arrayapp:MagnitudePattern')),':']);
            c.Tag=[obj.ShortName,'_MagnitudePatternTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:MagnitudePatternTT'));
            c.ValidAttributes={'real','nonempty'};
            uitext(obj,getString(message('phased:apps:arrayapp:dB')));
            connectPropertyAndControl(obj,'MagnitudePattern',c);
            obj.newrow;


            c=uieditv(obj,'zeros(181,361)','label',[getString(message('phased:apps:arrayapp:PhasePattern')),':']);
            c.Tag=[obj.ShortName,'_PhasePatternTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:PhasePatternTT'));
            c.ValidAttributes={'real','nonempty'};
            uitext(obj,getString(message('phased:apps:arrayapp:degrees')));
            connectPropertyAndControl(obj,'PhasePattern',c);
            obj.newrow;


            uitext(obj,[getString(message('phased:apps:arrayapp:BackBaffled')),':']);
            c=uicheckbox(obj);
            c.Tag=[obj.ShortName,'_BackBaffledTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:BackBaffledTT'));
            connectPropertyAndControl(obj,'IsBackBaffled',c);
            obj.newrow


            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:CosinePower')),':']);
            c.Tag=[obj.ShortName,'_CosinePowerTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:CosinePowerTT'));
            c.ValidAttributes={'real','>=',1,'size',[1,2]};
            connectPropertyAndControl(obj,'CosinePower',c);
            obj.newrow

        end



        function addSignalFrequenciesControl(obj)
            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:Frequency')),':']);
            c.Tag=[obj.ShortName,'_SignalFreqsTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:FrequencyTT'));
            c.ValidAttributes={'real','vector'};
            c.ValidationFunction=@sigdatatypes.validateFrequency;
            uitext(obj,getString(message('phased:apps:arrayapp:Hz')));
            connectPropertyAndControl(obj,'SignalFreqs',c);
            obj.newrow;
        end

        function addPropSpeedControl(obj)
            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:PropagationSpeed')),':']);
            c.Tag=[obj.ShortName,'_PropSpeedTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:PropagationSpeedTT'));
            c.ValidAttributes={'real','scalar','positive'};
            c.ValidationFunction=@sigdatatypes.validateSpeed;
            uitext(obj,[getString(message('phased:apps:arrayapp:meter')),'/'...
            ,getString(message('phased:apps:arrayapp:second'))]);
            connectPropertyAndControl(obj,'PropSpeed',c);
            obj.newrow;
        end

        function addSteeringControl(obj)

            uitext(obj,[getString(message('phased:apps:arrayapp:Steering')),':']);
            c=uicheckbox(obj);
            c.Tag=[obj.ShortName,'_SteeringTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:SteeringTT'));
            connectRowVisToControl(obj,[obj.ShortName,'_SteeringAnglesTag'],c,1,true);
            connectRowVisToControl(obj,[obj.ShortName,'_PhaseShiftBitsTag'],c,1,true);
            connectPropertyAndControl(obj,'SteeringIsOn',c);
            obj.newrow


            c=uieditv(obj,'[0;0]','label',[getString(message('phased:apps:arrayapp:SteeringAngles')),':']);
            c.Tag=[obj.ShortName,'_SteeringAnglesTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:SteeringAnglesTT'));
            c.ValidationFunction=@sigdatatypes.validateAzElAngle;
            uitext(obj,getString(message('phased:apps:arrayapp:degrees')));
            connectPropertyAndControl(obj,'SteeringAngles',c);
            obj.newrow;


            c=uieditv(obj,'0','label',[getString(message('phased:apps:arrayapp:PhaseShiftBits')),':']);
            c.Tag=[obj.ShortName,'_PhaseShiftBitsTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:PhaseShiftBitsTT'));
            c.ValidationFunction=@validateBits;

            uitext(obj,getString(message('phased:apps:arrayapp:bits')));
            connectPropertyAndControl(obj,'PhaseShiftBits',c);
            obj.newrow;

        end

        function addTaperDropdown(obj,secondaryPrefix,titlePrefix)









            if nargin<2
                prefix=obj.ShortName;
                secondaryPrefix='';
            else
                prefix=[obj.ShortName,'_',secondaryPrefix];
            end

            if nargin<3
                titlePrefix='';
            end

            sPre=secondaryPrefix;


            c=uipopup(obj,phased.apps.internal.SensorArrayViewer.TaperType.names,...
            'label',[getString(message(['phased:apps:arrayapp:',titlePrefix,'Taper'])),':']);
            c.Tag=[prefix,'_TaperDDTag'];
            c.TooltipString=getString(message(['phased:apps:arrayapp:',titlePrefix,'TaperTT']));
            connectRowVisToControl(obj,[prefix,'_SidelobeAttenuationTag'],c,{phased.apps.internal.SensorArrayViewer.TaperType.Chebyshev.Name,...
            phased.apps.internal.SensorArrayViewer.TaperType.Taylor.Name},true);
            connectRowVisToControl(obj,[prefix,'_BetaTag'],c,phased.apps.internal.SensorArrayViewer.TaperType.Kaiser.ID,true);
            connectRowVisToControl(obj,[prefix,'_NbarTag'],c,phased.apps.internal.SensorArrayViewer.TaperType.Taylor.ID,true);
            connectRowVisToControl(obj,[prefix,'_CustomTaperTag'],c,phased.apps.internal.SensorArrayViewer.TaperType.Custom.ID,true);
            connectPropertyAndControl(obj,[sPre,'TaperTypeIndex'],c,'value');
            obj.newrow;


            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:SidelobeAttenuation')),':']);
            c.Tag=[prefix,'_SidelobeAttenuationTag'];
            c.TooltipString=getString(message(['phased:apps:arrayapp:SidelobeLevel',titlePrefix,'TT']));
            c.ValidAttributes={'positive','scalar','finite','nonnan','nonempty','real'};
            uitext(obj,getString(message('phased:apps:arrayapp:dB')));
            connectPropertyAndControl(obj,[sPre,'SidelobeAttenuation'],c);
            obj.newrow;


            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:nbar')),':']);
            c.Tag=[prefix,'_NbarTag'];
            c.TooltipString=getString(message(['phased:apps:arrayapp:nbarTaylor',titlePrefix,'TT']));
            c.ValidAttributes={'positive','scalar','integer','finite','nonnan','nonempty','real'};
            connectPropertyAndControl(obj,[sPre,'Nbar'],c);
            obj.newrow;


            c=uieditv(obj,'label',[getString(message('phased:apps:arrayapp:beta')),':']);
            c.Tag=[prefix,'_BetaTag'];
            c.TooltipString=getString(message(['phased:apps:arrayapp:betaKaiser',titlePrefix,'TT']));
            c.ValidAttributes={'scalar','finite','nonnan','nonempty','real'};
            connectPropertyAndControl(obj,[sPre,'Beta'],c);
            obj.newrow;


            c=uieditvc(obj,'label',[getString(message('phased:apps:arrayapp:CustomTaper')),':']);
            c.Tag=[prefix,'_CustomTaperTag'];
            c.TooltipString=getString(message(['phased:apps:arrayapp:CustomTaper',titlePrefix,'TT']));
            c.ValidAttributes={'finite','nonnan','nonempty','vector'};
            connectPropertyAndControl(obj,[sPre,'CustomTaper'],c);
            obj.newrow;
        end

        function addTaperCustomEdit(obj)
            c=uieditvc(obj,'label',[getString(message('phased:apps:arrayapp:CustomTaper')),':']);
            c.Tag=[obj.ShortName,'_CustomTaperTag'];
            c.TooltipString=getString(message('phased:apps:arrayapp:CustomTaperTT'));
            c.ValidAttributes={'finite','nonnan','nonempty','vector'};
            connectPropertyAndControl(obj,'CustomTaper',c);
            obj.newrow;
        end

    end

    methods

        function verifyParameters(~,pending,~)









            curET=phased.apps.internal.SensorArrayViewer.ElementType.getElementAtPos(pending.ElementTypeIndex);
            if curET==phased.apps.internal.SensorArrayViewer.ElementType.CustomAntenna
                FV=pending.FrequencyVector;
                FR=pending.FrequencyResponse;
                AA=pending.AzimuthAngles;
                EA=pending.ElevationAngles;
                MP=pending.MagnitudePattern;
                PP=pending.PhasePattern;

                if length(EA)~=size(MP,1)||length(AA)~=size(MP,2)||(size(MP,3)~=1&&size(MP,3)~=length(FV))
                    e=MException('SensorArray:InvalidDimensions',['Expected Magnitude Pattern to be of size ',num2str(length(EA)),'x',num2str(length(AA)),'xL where L is either 1 or the length of the Frequency Vector']);



                    throwAsCaller(e);
                end

                if length(EA)~=size(PP,1)||length(AA)~=size(PP,2)||(size(PP,3)~=1&&size(PP,3)~=length(FV))
                    e=MException('SensorArray:InvalidDimensions',['Expected Phase Pattern to be of size ',num2str(length(EA)),'x',num2str(length(AA)),'xL where L is either 1 or the length of the Frequency Vector']);



                    throwAsCaller(e);
                end

                if length(FR)~=length(FV)
                    e=MException('SensorArray:InvalidDimensions','Expected Frequency Vector to have same length as Frequency Response');
                    throwAsCaller(e);
                end



                h=phased.CustomAntennaElement('FrequencyVector',FV,...
                'FrequencyResponse',FR,...
                'AzimuthAngles',AA,...
                'ElevationAngles',EA,...
                'MagnitudePattern',MP,...
                'PhasePattern',PP);
                step(h,0,0);

            end


            SA=pending.SteeringAngles;
            isSteered=pending.SteeringIsOn;
            SF=pending.SignalFreqs;
            if isSteered&&~isscalar(SF)&&size(SA,2)~=1&&length(SF)~=size(SA,2)
                e=MException(message('phased:apps:arrayapp:InvalidNumElements','signal frequencies','steering angles'));
                throwAsCaller(e);
            end



            PSB=pending.PhaseShiftBits;
            isSteered=pending.SteeringIsOn;
            SF=pending.SignalFreqs;
            SA=pending.SteeringAngles;
            if isSteered&&~isscalar(PSB)

                if((~isscalar(SF)&&length(SF)~=length(PSB)))
                    e=MException(message('phased:apps:arrayapp:InvalidNumElements','signal frequencies','phase shift quantization bits'));
                    throwAsCaller(e);
                elseif((size(SA,2)~=1&&size(SA,2)~=length(PSB)))
                    e=MException(message('phased:apps:arrayapp:InvalidNumElements','steering angles','phase shift quantization bits'));
                    throwAsCaller(e);

                end
            end


        end

        function verifyCustomTaper(obj,pending,~)
            customTaper=pending.CustomTaper;
            nE=obj.getArraySizeWithoutSave(pending);
            if~isscalar(customTaper)&&numel(customTaper)~=nE
                e=MException('SensorArray:InvalidDimensions','Expected Custom Taper to be scalar or have one entry for each element');
                throwAsCaller(e);
            end
        end

        function validateElLimit(obj,pending,~)

            numElements=obj.getArraySizeWithoutSave(pending);
            if numElements>obj.Application.Settings.NumElLimit
                choice=questdlg(getString(message('phased:apps:arrayapp:warnstring')),...
                getString(message('phased:apps:arrayapp:warndlgName')),...
                getString(message('phased:apps:arrayapp:yes')),...
                getString(message('phased:apps:arrayapp:no')),...
                getString(message('phased:apps:arrayapp:no')));
                if strcmp(choice,getString(message('phased:apps:arrayapp:no')))
                    error('SensorArray:NumElementsExceeded','NOSHOW');
                end

                obj.Application.Settings.NumElLimit=numElements;
            end


            if obj.Application.Visualization.getCurViewType()==phased.apps.internal.SensorArrayViewer.ViewType.ArrayDirectivity3D...
                &&numElements>obj.Application.Settings.NumElLimit3D
                choice=questdlg(getString(message('phased:apps:arrayapp:warn3dplotstring')),...
                getString(message('phased:apps:arrayapp:warndlgName')),...
                getString(message('phased:apps:arrayapp:yes')),...
                getString(message('phased:apps:arrayapp:no')),...
                getString(message('phased:apps:arrayapp:no')));
                if strcmp(choice,getString(message('phased:apps:arrayapp:no')))
                    error('SensorArray:NumElementsExceeded','NOSHOW');
                end

                obj.Application.Settings.NumElLimit3D=numElements;
            end
        end
    end

    methods
        function genCodeTaper(obj,mcode)
            taperType=obj.getCurTaperType();
            if taperType~=phased.apps.internal.SensorArrayViewer.TaperType.None
                mcode.addcr('%Calculate Taper');
                SLA=[];
                Beta=[];
                Nbar=[];
                Custom=[];
                if isprop(obj,'SidelobeAttenuation')
                    SLA=obj.SidelobeAttenuation;
                end
                if isprop(obj,'Beta')
                    Beta=obj.Beta;
                end
                if isprop(obj,'Nbar')
                    Nbar=obj.Nbar;
                end
                if isprop(obj,'CustomTaper')
                    Custom=obj.CustomTaper;
                end
                taperType.genCode(mcode,'wind',...
                obj.getArraySize(),SLA,Beta,Nbar,Custom,obj.StringValues.CustomTaper);
                mcode.addcr('h.Taper = wind;');
            end
        end
    end

    methods(Access=protected)
        function expandRangeForFreq(obj)



            if obj.getCurElementType()==phased.apps.internal.SensorArrayViewer.ElementType.CustomAntenna
                return
            end

            obj.FreqRange=[0,1e20];
            if(obj.FreqRange(1)>min(obj.SignalFreqs))
                obj.FreqRange(1)=min(obj.SignalFreqs);
            elseif(obj.FreqRange(2)<max(obj.SignalFreqs))
                obj.FreqRange(2)=max(obj.SignalFreqs);
            end
        end
    end

    methods(Abstract,Access=protected)
        updateArrayObj(obj)




        as=getArraySizeWithoutSave(obj,pending)
    end

    methods(Abstract)
        genCode(obj,mcode)
    end
end

function x=validateBits(x,funcname,varname,varargin)











%#codegen
%#ok<*EMCA>

    validateattributes(x,{'double'},{'finite','nonnan','nonempty',...
    'nonnegative','integer','vector'},funcname,varname);

    if~isempty(varargin)
        validateattributes(x,{'double'},varargin{:},funcname,varname);
    end
end
