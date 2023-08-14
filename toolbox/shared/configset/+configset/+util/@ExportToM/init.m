function init(obj)


    obj.containCustomCC=false;
    obj.buffer={};
    obj.generateHeader;
    obj.generateVersion;
    obj.generateEncoding;
    obj.generateOrder;
    obj.generateSwitchTarget;
    obj.generateHardwareBoard;
    obj.generateCodeInterfacePackaging;
    obj.generateSolver;

    cs=obj.cs;
    n=cs.Components;
    for i=1:length(n)
        cc=cs.Components(i);
        if isa(cc,'hdlcoderui.hdlcc')
            obj.containCustomCC=true;
            obj.generateHDLComponent(cc);
        elseif isa(cc,'Simulink.CustomCC')&&~isa(cc,'SlCovCC.ConfigComp')
            obj.containCustomCC=true;
            obj.generateCustomComponent(cc);
        else
            obj.generateComponent(cc);
        end
    end


