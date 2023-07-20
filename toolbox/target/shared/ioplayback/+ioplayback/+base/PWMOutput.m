classdef PWMOutput<ioplayback.base.PWM





%#codegen
    properties(Hidden,Nontunable)
        Logo='Generic'
    end

    methods
        function obj=PWMOutput(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            flag=isInactivePropertyImpl@ioplayback.base.PWM(obj,prop);
            if ismember(prop,{'EnableInputFrequency','NotificationType'})
                flag=true;
            elseif isequal(prop,'PWMSync')
                flag=isempty(obj.PWMSync)||~obj.EnablePWMSync;
            elseif isequal(prop,'EnablePWMSync')
                flag=isempty(obj.PWMSync);
            end
        end


        function maskDisplayCmds=getMaskDisplayImpl(obj)
            x=1:12;
            y=double(abs(0:1/5:1)>=0.5);
            y=[y,flip(y)];
            x=[x(1:3),3.999,x(4:9),9.001,x(10:end)];
            y=[y(1:3),0,y(4:9),0,y(10:end)]*45+30;
            x=[x,x+11];
            y=[y,y];

            x1=1:32;
            y1=double(abs(0:1/15:1)>=0.5);
            y1=[y1,flip(y1)];
            x1=[x1(1:8),8.999,x1(9:24),24.001,x1(25:end)];
            y1=[y1(1:8),0,y1(9:24),0,y1(25:end)]*45+30;

            x=[x,x1+x(end)]+22;
            y=[y,y1];
            maskDisplayCmds=[...
            ['color(''white'');',newline],...
            ['plot([100,100,100,100]*1,[100,100,100,100]*1);',newline],...
            ['plot([100,100,100,100]*0,[100,100,100,100]*0);',newline],...
            ['color(''blue'');',newline],...
            ['text(99, 92, ''',obj.Logo,''', ''horizontalAlignment'', ''right'');',newline],...
            ['color(''black'');',newline],...
            ['plot([',num2str(x),'],[',num2str(y),'])',newline],...
            ['text(50, 15, ''Pin: ',num2str(obj.Pin),''' ,''horizontalAlignment'', ''center'');',newline],...
            ];
        end
    end

    methods(Static,Access=protected)

        function header=getHeaderImpl()
            header=matlab.system.display.Header(mfilename('class'),...
            'ShowSourceLink',false,...
            'Title','PWM Output',...
            'Text',['Generate square waveform on the specified output pin.'...
            ,'The block input controls the duty cycle of the square waveform. An'...
            ,' input value of 0 produces a 0 percent duty cycle and an input value'...
            ,[' of 100 produces a 100 percent duty cycle.',newline,newline],...
'Enter the number of the PWM output pin. Do not assign the same pin'...
            ,' number to multiple blocks within a model.']);
        end

        function[groups,PropertyList]=getPropertyGroupsImpl
            [groups,PropertyListOut]=ioplayback.base.PWM.getPropertyGroupsImpl;

            if nargout>1
                PropertyList=PropertyListOut;
            end
        end
    end
end

