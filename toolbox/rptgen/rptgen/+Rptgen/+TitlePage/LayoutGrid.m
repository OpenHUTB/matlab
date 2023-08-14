classdef LayoutGrid<handle



    properties

        NumberOfColumns=1
        NumberOfRows=16
        Height=''
        HeightUnit='in'
        Width=''
        WidthUnit='in'
        Show=false;

    end

    methods

        function this=LayoutGrid()
        end

        function save(this,docFormat,elFormat)
            elLayout=docFormat.createElement(Rptgen.TitlePage.LayoutGrid.getTagName());
            elLayout.setAttribute('class',class(this));
            elLayout.setAttribute('ncols',num2str(this.NumberOfColumns));
            elLayout.setAttribute('nrows',num2str(this.NumberOfRows));
            elLayout.setAttribute('height',this.Height);
            elLayout.setAttribute('height-unit',this.HeightUnit);
            elLayout.setAttribute('width-unit',this.WidthUnit);
            elFormat.appendChild(elLayout);
        end

    end

    methods(Static)

        function tagName=getTagName()
            tagName='tp_layout';
        end

        function layout=load(elLayout)
            ctor=str2func(char(elLayout.getAttribute('class')));
            layout=ctor();
            layout.NumberOfColumns=str2double(char(elLayout.getAttribute('ncols')));
            layout.NumberOfRows=str2double(char(elLayout.getAttribute('nrows')));
            layout.Height=char(elLayout.getAttribute('height'));
            layout.HeightUnit=char(elLayout.getAttribute('height-unit'));
            layout.Width=char(elLayout.getAttribute('width'));
            layout.WidthUnit=char(elLayout.getAttribute('width-unit'));
        end
    end

end