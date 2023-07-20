

















classdef LVAnalysisPanel<handle

    properties(Access=private,Hidden)

Position

        MainFigure matlab.ui.Figure

FieldList

FieldInfo

DataTable
    end

    properties(Constant)
        MARGIN=2;
    end

    properties(Dependent)

NUMENTRIES
    end

    methods



        function this=LVAnalysisPanel(figure,fieldList)
            this.MainFigure=figure;
            this.FieldList=fieldList;
            this.computePosition();
            this.DataTable=uitable('Parent',this.MainFigure,'Position',this.Position,...
            'RowName',{},'Data',cell(numel(this.FieldList,2)),'ColumnName',{});
            this.setUp();
        end




        function update(this,updateInfo)



            if~isequal(numel(updateInfo),this.NUMENTRIES)
                return;
            end

            this.FieldInfo=updateInfo;
            this.setUp();
        end




        function reset(this)
            this.FieldInfo={};
            this.setUp();
        end




        function resize(this)



            this.computePosition();
            this.setUp();
        end
    end




    methods(Access=private)

        function computePosition(this)



            this.Position=[];
            this.MainFigure.Units='pixels';

            this.Position(3)=this.MainFigure.Position(3)+this.MARGIN;

            this.Position(4)=this.MainFigure.Position(4)-this.MARGIN;

            this.Position(1)=this.MARGIN;
            this.Position(2)=this.MARGIN;

        end


        function setUp(this)



            if any(this.Position(:)<=0)
                return;
            end

            infoToDisplay=this.getTextToDisplay();

            this.DataTable.Position=this.Position;
            this.DataTable.Data=infoToDisplay;
        end


        function infoToDisplay=getTextToDisplay(this)




            infoToDisplay=cell(this.NUMENTRIES,2);
            infoToDisplay(:,1)=this.FieldList;

            if isempty(this.FieldInfo)
                return;
            end

            for i=1:this.NUMENTRIES
                if ischar(this.FieldInfo{i})

                    infoToDisplay{i,2}=this.FieldInfo{i};

                elseif isstring(this.FieldInfo{i})

                    infoToDisplay{i,2}=char(this.FieldInfo{i});

                elseif isnumeric(this.FieldInfo{i})
                    if numel(this.FieldInfo{i})==2

                        infoToDisplay{i,2}=['[ ',...
                        int2str(this.FieldInfo{i}(1)),' , ',...
                        int2str(this.FieldInfo{i}(2)),' ]'];

                    else

                        infoToDisplay{i,2}=int2str(this.FieldInfo{i});
                    end
                else

                    infoToDisplay{i,2}=' ';
                end
            end
        end
    end




    methods
        function numEntries=get.NUMENTRIES(this)
            numEntries=numel(this.FieldList);
        end
    end
end