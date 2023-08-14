classdef colorManager<handle
    properties(SetAccess=private,GetAccess=private)
        colors={'cyan','magenta','orange','lightBlue','red','green','blue','darkGreen'};
    end

    methods

        function thisMgr=colorManager(varargin)
            if(nargin>0)
                thisMgr.colors=varargin(1);
            end
        end



        function setHiliteScheme1(thisMgr,index)
            HILITEDATA=struct('HiliteType','user1','ForegroundColor','black','BackgroundColor',thisMgr.colors{index});
            set_param(0,'HiliteAncestorsData',HILITEDATA);
        end


        function setHiliteScheme2(thisMgr,index)
            HILITEDATA=struct('HiliteType','user2','ForegroundColor',thisMgr.colors{index},'BackgroundColor',thisMgr.colors{index});
            set_param(0,'HiliteAncestorsData',HILITEDATA);
        end


        function setHiliteScheme3(thisMgr,index)
            HILITEDATA=struct('HiliteType','user3','ForegroundColor',thisMgr.colors{index},'BackgroundColor','blue');
            set_param(0,'HiliteAncestorsData',HILITEDATA);
        end




        function annotate(thisMgr,pos,path,text,index)
            add_block('built-in/Note',[path,'/',text],'Position',pos,'BackgroundColor',thisMgr.colors{index},'ForegroundColor','black');
        end



        function annotateValueLabel(thisMgr,port,text)
            Simulink.AnnotationGateway.Annotate(port,[text,'(ns)']);
        end
    end
end