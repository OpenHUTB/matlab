classdef Frameset<Advisor.Element









    properties(Access='public')
        Frames=[];
        FramesetContainer=[];
    end


    methods(Access='public')


        function this=Frameset()
            this.FramesetContainer=Advisor.Element;
        end


        function addFrameItem(this,item)
            if~isa(item,'Advisor.Frame')&&...
                ~isa(item,'Advisor.Frameset')&&...
                ~isa(item,'Advisor.Element')
                item=Advisor.Frame;
            end
            this.Frames=[this.Frames;item];
        end


        function setAttribute(this,attrib,value)
            this.FramesetContainer.setAttribute(attrib,value);
        end



        function outputString=emitHTML(this)

            outputString='';
            this.FramesetContainer.setTag('frameset');
            for i=1:length(this.Frames)
                outputString=[outputString,this.Frames(i).emitHTML];%#ok
            end
            this.FramesetContainer.setContent(outputString);
            outputString=this.FramesetContainer.emitHTML;
        end
    end
end

