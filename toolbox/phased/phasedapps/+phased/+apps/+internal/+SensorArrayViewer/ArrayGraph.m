


classdef ArrayGraph<handle

    properties(Access=protected)
Panel
hAxes
ViewAngle

Application
    end

    properties
NeedsRedraw
CanRotate
CanPan
    end

    methods
        function obj=ArrayGraph(App,panel,tag)
            obj.NeedsRedraw=true;

            obj.Panel=uipanel(panel,...
            'Position',[0.02,0.01,0.97,0.99],...
            'Visible','off',...
            'BackgroundColor',239/255*ones(1,3));

            obj.hAxes=axes(...
            'Parent',obj.Panel,...
            'Color','none',...
            'Visible','off',...
            'Tag',['axes_',tag]);

            obj.Application=App;
        end

        function update(~)



        end
    end

    methods(Sealed)

        function show(obj)




            if~isempty(obj.hAxes.Children)
                obj.ViewAngle=obj.hAxes.View;
            end

            if obj.NeedsRedraw
                cla(obj.hAxes);
                obj.draw();
                uistack(obj.Panel,'top');
            end
            obj.update();
            obj.Panel.Visible='on';
            obj.NeedsRedraw=false;
        end

        function hide(obj)
            obj.Panel.Visible='off';
        end

        function reset(obj)
            obj.NeedsRedraw=true;
            cla(obj.hAxes);
            obj.ViewAngle=[];
        end

        function setRotate(obj,onOff)
            if obj.CanRotate
                rotate3d(obj.hAxes,onOff);
            else
                rotate3d(obj.hAxes,'off');
            end
        end

        function setPan(obj,onOff)
            if obj.CanPan
                pan(obj.Application.FigureHandle,onOff);
            else
                pan(obj.Application.FigureHandle,'off');
            end
        end

        function genCodeTitle(obj,mcode)


            curAT=obj.Application.Settings.getCurArrayType();

            mcode.addcr('title = get(hAxes, ''title'');');
            mcode.addcr('title_str = get(title, ''String'');');
            mcode.addcr('%Modify the title');
            mcode.addcr(['[Fval, ~, Fletter] = engunits(',num2str(curAT.SignalFreqs(1)),');']);

            if curAT.SteeringIsOn
                SA=curAT.SteeringAngles;
                mcode.addcr(['steeringString = ''',getString(message('phased:apps:arrayapp:d3titlesteer',num2str(SA(1)),num2str(SA(2)))),''';']);
            else
                mcode.addcr(['steeringString = ''',getString(message('phased:apps:arrayapp:NoSteering')),''';']);
            end

            mcode.addcr('title_str = [title_str sprintf(''\n'') num2str(Fval) '' '' Fletter ''Hz '' steeringString];');
            mcode.addcr('set(title, ''String'', title_str);');
        end

    end

    methods(Access=protected)

        function updateTitle(obj)


            curAT=obj.Application.Settings.getCurArrayType();

            title=get(obj.hAxes,'title');
            title_str=get(title,'String');

            [Fval,~,Fletter]=engunits(curAT.SignalFreqs(1));

            steeringString=getString(message('phased:apps:arrayapp:NoSteering'));
            if curAT.SteeringIsOn
                SA=curAT.SteeringAngles;
                steeringString=getString(message('phased:apps:arrayapp:d3titlesteer',num2str(SA(1)),num2str(SA(2))));
            end

            title_str=[title_str,sprintf('\n')...
            ,num2str(Fval),' ',Fletter,[getString(message('phased:apps:arrayapp:Hz')),' '],steeringString];
            set(title,'String',title_str);
        end

    end

    methods(Abstract)
        draw(obj)
        genCode(obj,mcode)
    end

end

