function gClear(this,varargin)







    if strcmpi(varargin(1),'language')
        this.Partition.Lang='';
        for i=1:length(this.ChildNode)
            comp=this.ChildNode{i};
            comp.gClear('language');
        end
    elseif strcmpi(varargin(1),'generatedHDLCode')
        if~isa(this,'eda.internal.component.BlackBox')
            this.HDL=this.hdlcodeinit;
            this.HDLFiles='';
            for i=1:length(this.ChildNode)
                comp=this.ChildNode{i};
                comp.gClear('generatedHDLCode');
            end
        end
    elseif strcmpi(varargin(1),'all')
        if~isa(this,'eda.internal.component.BlackBox')

            for i=1:length(this.ChildNode)
                comp=this.ChildNode{i};
                comp.gClear('all');
            end
            this.ChildNode='';
            this.ChildEdge='';
        end
    else
        error(message('EDALink:Node:gClear:vlearoptionerror'));
    end

end

