classdef Variant<handle




    properties(SetAccess=private)
        Source='';
        Variants=[];
    end
    properties
        Name='';
    end
    methods
        function this=Variant(sourceFile)
            [~,~,sourceExt]=fileparts(sourceFile);
            assert(strcmp(sourceExt,'.sscx'));
            this.Source=sourceFile;
            parse(this);
        end

        function this=parse(this)
            p=matlab.io.xml.dom.Parser;
            xmlInfo=p.parseFile(this.Source);
            assert(xmlInfo.getElementsByTagName('block').getLength==1);
            assert(xmlInfo.getElementsByTagName('block').item(0).hasAttribute('name'));
            this.Name=sprintf(char(xmlInfo.getElementsByTagName('block').item(0).getAttribute('name')));

            num=xmlInfo.getElementsByTagName('variant').getLength;
            assert(num>=1);
            v=struct('name',cell(1,num),'source',cell(1,num));
            for idx=1:num
                v(idx).source=char(xmlInfo.getElementsByTagName('variant').item(idx-1).getAttribute('source'));
                v(idx).name=sprintf(char(xmlInfo.getElementsByTagName('variant').item(idx-1).getAttribute('name')));
            end
            this.Variants=v;
        end

    end
end


