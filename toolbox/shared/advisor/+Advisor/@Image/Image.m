classdef Image<Advisor.Element

    properties(Access='public')
        ImageSource='';
        Hyperlink='';
    end


    methods(Access='public')

        function outputString=emitHTML(this)






            tagAttributes='';
            if~isempty(this.TagAttributes)
                for i=1:size(this.TagAttributes,1)
                    tagAttributes=[tagAttributes,' ',...
                    this.TagAttributes{i,1},'="',...
                    this.TagAttributes{i,2},'"'];%#ok<AGROW>
                end
            end


            outputString=['<img src="',this.ImageSource,'" ',tagAttributes,'/>'];


            if~isempty(this.Hyperlink)
                temp=Advisor.Element;
                temp.setContent(outputString);
                temp.setTag('a');
                temp.setAttribute('href',this.Hyperlink);
                outputString=temp.emitHTML;
            end
        end


        function setHyperlink(this,hyperlink)
            if ischar(hyperlink)
                this.Hyperlink=hyperlink;
            else
                DAStudio.error('MATLAB:class:MustBeString');
            end
        end


        function setImageSource(this,imgsrc)
            if ischar(imgsrc)
                this.ImageSource=imgsrc;
            else
                DAStudio.error('Advisor:engine:MAInvalidaImageSourceMustBeString');
            end
        end
    end

end
