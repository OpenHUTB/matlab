classdef Control<handle






    properties
        Model(1,1){mustBeValid}
        View(1,1){mustBeValid}
    end

    properties(Access=private)
        ListenerHandles=event.listener.empty;
    end


    methods(Access=public)

        function obj=Control(model,view)


            obj.Model=model;
            obj.View=view;



            obj.View.UIFigure.Name=getString(message(...
            'physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:name_UIFigure',obj.Model.blockname));


            obj.ListenerHandles(1)=listener(obj.Model,'ValueChanged',@(source,event)obj.ModelValueChanged(source,event));

            notify(obj.Model,'ValueChanged')

        end


        function delete(obj)
            delete(obj.ListenerHandles);
            delete(obj.View);
            delete(obj.Model);
        end
    end

    methods(Access=private)
        function updateViewComponents(obj)

            obj.View.UIFigure.Visible='off';


            wMin=min(obj.Model.plotdata.wnd_radps(:));
            wMax=max(obj.Model.plotdata.wnd_radps(:));
            minX=wMin*60/2/pi;
            maxX=wMax*60/2/pi;
            xlim(obj.View.UIAxes,[minX,maxX])
            minY=min(obj.Model.plotdata.trqnd_Nm(:));
            maxY=max(obj.Model.plotdata.trqnd_Nm(:));
            ylim(obj.View.UIAxes,[minY,maxY])


            if obj.Model.plotdata.voltageSliderIsActive

                obj.View.VoltageSlider.Visible='on';
                obj.View.VoltageSliderLabel.Visible='on';
                obj.View.VoltageSlider.ValueChangedFcn=@(source,event)obj.SliderValueChanged(source,event);


                if isfield(obj.Model.plotdata,'v_vec_V')&&isfield(obj.Model.plotdata,'v_eff_vec_V')
                    lowLim=min(min(obj.Model.plotdata.v_vec_V,obj.Model.plotdata.v_eff_vec_V));
                    upLim=max(max(obj.Model.plotdata.v_vec_V,obj.Model.plotdata.v_eff_vec_V));
                elseif isfield(obj.Model.plotdata,'v_vec_V')
                    lowLim=min(obj.Model.plotdata.v_vec_V);
                    upLim=max(obj.Model.plotdata.v_vec_V);
                else
                    lowLim=min(obj.Model.plotdata.v_eff_vec_V);
                    upLim=max(obj.Model.plotdata.v_eff_vec_V);
                end
                lowLim=round(lowLim);
                upLim=round(upLim);

                obj.View.VoltageSlider.Limits=[lowLim,upLim];
                obj.View.VoltageSlider.MajorTicks=round(linspace(lowLim,upLim,7),4,'significant');
            end
            if obj.Model.plotdata.temperatureSliderIsActive

                obj.View.TemperatureSlider.Visible='on';
                obj.View.TemperatureSliderLabel.Visible='on';
                obj.View.TemperatureSlider.ValueChangedFcn=@(source,event)obj.SliderValueChanged(source,event);


                lowLim=round(min(obj.Model.plotdata.T_vec_K));
                upLim=round(max(obj.Model.plotdata.T_vec_K));
                obj.View.TemperatureSlider.Limits=[lowLim,upLim];
                obj.View.TemperatureSlider.MajorTicks=round(linspace(lowLim,upLim,7),4,'significant');
            end


            if~obj.Model.plotdata.voltageSliderIsActive&&~obj.Model.plotdata.temperatureSliderIsActive

                obj.View.UIAxes.Layout.Row=[1,3];

            elseif obj.Model.plotdata.voltageSliderIsActive&&~obj.Model.plotdata.temperatureSliderIsActive

                obj.View.UIAxes.Layout.Row=[1,2];
                obj.View.VoltageSlider.Layout.Row=3;
                obj.View.VoltageSliderLabel.Layout.Row=3;

            elseif~obj.Model.plotdata.voltageSliderIsActive&&obj.Model.plotdata.temperatureSliderIsActive

                obj.View.UIAxes.Layout.Row=[1,2];

            elseif obj.Model.plotdata.voltageSliderIsActive&&obj.Model.plotdata.temperatureSliderIsActive

            end



            voltage=obj.View.VoltageSlider.Value;
            temperature=obj.View.TemperatureSlider.Value;
            interpolatedPlotData=obj.Model.getInterpolatedPlotData(voltage,temperature);
            obj.plotTorqueEnvelopesAndEfficiencyMap(interpolatedPlotData);



            obj.View.UIFigure.Visible='on';

        end
    end



    methods(Access=protected)


        function ModelValueChanged(obj,~,~)
            obj.updateViewComponents();
        end

        function SliderValueChanged(obj,~,~)
            voltage=obj.View.VoltageSlider.Value;
            temperature=obj.View.TemperatureSlider.Value;
            interpolatedPlotData=obj.Model.getInterpolatedPlotData(voltage,temperature);
            obj.plotTorqueEnvelopesAndEfficiencyMap(interpolatedPlotData);
        end

    end


    methods(Access=protected)

        function plotTorqueEnvelopesAndEfficiencyMap(obj,interpolatedPlotData)


            effValid=interpolatedPlotData.effValid;
            wrpm=interpolatedPlotData.wrpm;
            trq=interpolatedPlotData.trq;
            contour_levels=obj.Model.plotdata.contour_levels;
            w_rpm_vec=interpolatedPlotData.w_rpm_vec;
            torque_envelope_Nm=interpolatedPlotData.torque_envelope_Nm;
            overtorque_choice=obj.Model.blockinfo.DropdownChoices.overtorque_param;
            if isequal(overtorque_choice,ee.enum.electromech.overtorque.yes)
                torque_intermittent_envelope_Nm=interpolatedPlotData.torque_intermittent_envelope_Nm;
            end

            effValid=round(effValid,5);

            hold(obj.View.UIAxes,"on");


            contourf(obj.View.UIAxes,wrpm,trq,effValid,contour_levels,"ShowText","on");
            colorbar(obj.View.UIAxes);


            hPlotTor=plot(obj.View.UIAxes,w_rpm_vec,torque_envelope_Nm,"LineWidth",3,"Color","green");

            if isequal(overtorque_choice,ee.enum.electromech.overtorque.no)
                legend(hPlotTor,getString(message('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:legend_Torque')))
            else
                hPlotTorIntrmt=plot(obj.View.UIAxes,w_rpm_vec,torque_intermittent_envelope_Nm,"LineWidth",3,"Color","red");
                legend([hPlotTor,hPlotTorIntrmt],...
                {getString(message('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:legend_ContinuousTorque')),...
                getString(message('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:legend_IntermittentTorque'))});
            end

        end

    end

end


function mustBeValid(value)
    if~isa(value,'double')&&~isvalid(value)
        pm_error('physmod:ee:library:comments:utils:mask:plotMotorDriveEfficiencyMap:error_ControlInputIsInvalid');
    end
end

