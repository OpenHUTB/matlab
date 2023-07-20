classdef Panel<handle




    properties
        slVerifyPanel;
        handle;
container
        parentHandle;
    end

    methods
        function this=Panel(slVerifyPanel,parentH)
            this.slVerifyPanel=slVerifyPanel;
            this.parentHandle=parentH;
            if~isempty(this.parentHandle)
                this.drawPanel()
            end

        end

        function drawPanel(this)
            this.handle=uipanel('Parent',this.parentHandle,'Units','pixel');
        end

        function setPosition(this,pos)
            set(this.handle,'Position',pos);
        end

        function setVisible(this,tf)
            set(this.handle,'Visible',bool2OnOff(tf));
        end

        function pos=getPosition(this)
            pos=get(this.handle,'Position');
        end

        function tf=isVisible(this)
            tf=onOff2bool(get(this.handle,'Visible'));
        end
    end
end

function str=bool2OnOff(tf)
    if tf
        str='on';
    else
        str='off';
    end
end
function tf=onOff2bool(str)
    if strcmp(str,'on')
        tf=true;
    else
        tf=false;
    end
end
