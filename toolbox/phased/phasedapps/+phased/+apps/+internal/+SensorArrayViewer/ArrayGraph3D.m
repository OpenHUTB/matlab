


classdef ArrayGraph3D<phased.apps.internal.SensorArrayViewer.ArrayGraph

    properties
AD3DOption

UserData

    end

    properties(Access=private)
hSmallAxes
    end

    methods

        function obj=ArrayGraph3D(App,panel,op)
            obj=obj@phased.apps.internal.SensorArrayViewer.ArrayGraph(App,panel,['3D_',op.Tag]);

            obj.AD3DOption=op;

            obj.hSmallAxes=axes('Tag',['axes_small_geometry_',op.Tag],...
            'Parent',obj.Panel,...
            'Visible','off','Position',[0,0.8,0.2,0.2]);

            hlink=linkprop([obj.hAxes,obj.hSmallAxes],'View');
            obj.UserData.hlink=hlink;

            obj.CanRotate=true;
            obj.CanPan=false;
        end

        function draw(obj)

            curAT=obj.Application.Settings.getCurArrayType();
            fmt=obj.AD3DOption.Format;
            h=curAT.ArrayObj;
            F=curAT.SignalFreqs;
            PS=curAT.PropSpeed;

            axes(obj.hAxes);
            tag=obj.hAxes.Tag;
            isSteered=curAT.SteeringIsOn;
            if strcmpi(fmt,'line')
                fmt='rectangular';
            elseif strcmpi(fmt,'uv')
                fmt='uv';
            else
                fmt='polar';
            end

            if isSteered
                w=curAT.SteerWeights;
                pattern(h,F(1),'PropagationSpeed',PS,...
                'Type','directivity',...
                'CoordinateSystem',fmt,...
                'weights',w(:,1));
            else
                pattern(h,F(1),'PropagationSpeed',PS,...
                'Type','directivity',...
                'CoordinateSystem',fmt);
            end
            set(obj.hAxes,'Tag',tag);
        end

        function update(obj)

            if obj.NeedsRedraw
                obj.updateTitle();
            end

            fmt=obj.AD3DOption.Format;


            if strcmp(fmt,'Polar')
                if obj.Application.Visualization.ShowGeometry
                    obj.drawSmallGeometry();
                else
                    cla(obj.hSmallAxes);
                end

                if~isempty(obj.ViewAngle)
                    view(obj.hAxes,obj.ViewAngle);
                end
            else
                view(obj.hAxes,0,90);
                axis(obj.hAxes,'square');
                if strcmp(fmt,'Line')
                    xlim(obj.hAxes,[-180,180]);
                    ylim(obj.hAxes,[-90,90]);
                end
            end

            axis(obj.hAxes,'vis3d');

        end

        function drawSmallGeometry(obj)

            viewArray(obj.Application.Settings.getCurArrayType().ArrayObj,...
            'Parent',obj.hSmallAxes);

            obj.hSmallAxes.Children(end).Tag=[obj.hSmallAxes.Tag,'_Scatter'];


        end


        function genCode(obj,mcode)

            curAT=obj.Application.Settings.getCurArrayType();
            isSteered=curAT.SteeringIsOn;
            PSB=curAT.PhaseShiftBits;
            weight_str='';
            if isSteered
                mcode.addcr('%Calculate Steering Weights');
                mcode.addcr('w = zeros(getNumElements(h), length(F));');
                if PSB(1)>0
                    mcode.addcr('SV = phased.SteeringVector(''SensorArray'',h, ''PropagationSpeed'', PS, ''NumPhaseShifterBits'', PSB(1));');
                else
                    mcode.addcr('SV = phased.SteeringVector(''SensorArray'',h, ''PropagationSpeed'', PS);');
                end
                mcode.addcr('%Find the weights');
                mcode.addcr('for idx = 1:length(F)');
                mcode.addcr('    w(:, idx) = step(SV, F(idx), SA(:, idx));');
                mcode.addcr('end');

                weight_str=',''weights'', w(:,1)';
            end

            mcode.addcr('%Plot 3d graph');
            if strcmpi(obj.AD3DOption.Format,'line')
                fmt='rectangular';
            elseif strcmpi(obj.AD3DOption.Format,'uv')
                fmt='uv';
            else
                fmt='polar';
            end
            mcode.addcr(['fmt = ''',fmt,''';']);
            mcode.addcr(['pattern(h, F(1), ''PropagationSpeed'', PS, ''Type'',''directivity'', ''CoordinateSystem'', fmt',weight_str,');']);
            mcode.addcr('%Adjust the view angles');
            if strcmp(obj.AD3DOption.Format,'Polar')
                if obj.Application.Visualization.ShowGeometry
                    mcode.addcr('hSmallAxes = axes(''Parent'', panel, ''Position'', [0 0.8 0.2 0.2]);');
                    mcode.addcr('hlink = linkprop([hAxes hSmallAxes],''View'');');
                    mcode.addcr('setappdata(fig, ''Lin1'', hlink);');
                    mcode.addcr('viewArray(h,''Parent'', hSmallAxes)');
                end
                mcode.addcr(['view(hAxes,',mat2str(obj.hAxes.View),');']);
            else
                mcode.addcr(['view(hAxes,',mat2str(obj.hAxes.View),');']);
                mcode.addcr('axis(hAxes,''square'');');
                if strcmp(obj.AD3DOption.Format,'Line')
                    mcode.addcr('xlim(hAxes,[-180,180]);');
                    mcode.addcr('ylim(hAxes,[-90,90]);');
                end
            end
            obj.genCodeTitle(mcode);
        end

    end

end

