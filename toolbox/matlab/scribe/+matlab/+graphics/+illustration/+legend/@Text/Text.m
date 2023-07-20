classdef(Sealed)Text<matlab.graphics.primitive.world.Group&matlab.graphics.mixin.Selectable





    properties(DeepCopy=true,Access={?tmatlab_graphics_illustration_legend_Text_Impl,...
        ?tLegendText,...
        ?matlab.graphics.illustration.Legend,...
        ?matlab.graphics.illustration.internal.AbstractLegend,...
        ?matlab.graphics.illustration.internal.AbstractChartIllustration})
        TextComp matlab.graphics.primitive.Text;
    end

    properties(Access={?matlab.graphics.illustration.Legend,...
        ?tmatlab_graphics_illustration_legend_Text_Impl,...
        ?tmatlab_graphics_illustration_Legend_Impl,...
        ?matlab.graphics.illustration.internal.AbstractLegend})

        Position matlab.internal.datatype.matlab.graphics.datatype.TextPosition=[0,0,0];
        HorizontalAlignment matlab.internal.datatype.matlab.graphics.datatype.HorizontalAlignment='left';
    end

    properties(Dependent=true)


        String matlab.internal.datatype.matlab.graphics.datatype.NumericOrString='';



        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];

        FontAngle matlab.internal.datatype.matlab.graphics.datatype.FontAngle='normal';

        FontName matlab.internal.datatype.matlab.graphics.datatype.FontName='Helvetica';

        FontSize matlab.internal.datatype.matlab.graphics.datatype.Positive=9;

        FontWeight matlab.internal.datatype.matlab.graphics.datatype.FontWeight='normal';

        Interpreter matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter='tex';
    end

    properties(Dependent=true,NeverAmbiguous)
        ColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        FontAngleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        FontNameMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        FontSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        FontWeightMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        InterpreterMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Dependent=true,Hidden=true)
        Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
        FontAngle_I matlab.internal.datatype.matlab.graphics.datatype.FontAngle='normal';
        FontName_I matlab.internal.datatype.matlab.graphics.datatype.FontName='Helvetica';
        FontSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive=9;
        FontWeight_I matlab.internal.datatype.matlab.graphics.datatype.FontWeight='normal';
        Interpreter_I matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter='tex';
    end

    properties(Dependent=true,Access={?matlab.graphics.illustration.Legend})
        Editing matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function val=get.String(hObj)
            val=hObj.TextComp.String;
        end

        function set.String(hObj,newValue)




            if iscell(newValue)
                newValue=strjoin(newValue,'\n');
            end







            if numel(newValue)>25000
                warning(message('MATLAB:legend:LargeStringLength'));
                hObj.TextComp.String='';
            else


                hObj.TextComp.String=deblank(newValue);
                hObj.MarkDirty('all');
            end
        end


        function val=get.Color(hObj)
            val=hObj.TextComp.Color;
        end

        function set.Color(hObj,newValue)
            hObj.TextComp.Color=newValue;
            hObj.MarkDirty('all');
        end

        function val=get.ColorMode(hObj)
            val=hObj.TextComp.ColorMode;
        end

        function set.ColorMode(hObj,newValue)
            hObj.TextComp.ColorMode=newValue;
            hObj.MarkDirty('all');
        end

        function val=get.Color_I(hObj)
            val=hObj.TextComp.Color_I;
        end

        function set.Color_I(hObj,newValue)
            hObj.TextComp.Color_I=newValue;
            hObj.MarkDirty('all');
        end



        function val=get.FontAngle(hObj)
            val=hObj.TextComp.FontAngle;
        end

        function set.FontAngle(hObj,newValue)
            hObj.TextComp.FontAngle=newValue;
            hObj.MarkDirty('all');
        end

        function val=get.FontAngleMode(hObj)
            val=hObj.TextComp.FontAngleMode;
        end

        function set.FontAngleMode(hObj,newValue)
            hObj.TextComp.FontAngleMode=newValue;
            hObj.MarkDirty('all');
        end

        function val=get.FontAngle_I(hObj)
            val=hObj.TextComp.FontAngle_I;
        end

        function set.FontAngle_I(hObj,newValue)
            hObj.TextComp.FontAngle_I=newValue;
            hObj.MarkDirty('all');
        end



        function val=get.FontName(hObj)
            val=hObj.TextComp.FontName;
        end

        function set.FontName(hObj,newValue)
            hObj.TextComp.FontName=newValue;
            hObj.MarkDirty('all');
        end

        function val=get.FontNameMode(hObj)
            val=hObj.TextComp.FontNameMode;
        end

        function set.FontNameMode(hObj,newValue)
            hObj.TextComp.FontNameMode=newValue;
            hObj.MarkDirty('all');
        end

        function val=get.FontName_I(hObj)
            val=hObj.TextComp.FontName_I;
        end

        function set.FontName_I(hObj,newValue)
            hObj.TextComp.FontName_I=newValue;
            hObj.MarkDirty('all');
        end



        function val=get.FontSize(hObj)
            val=hObj.TextComp.FontSize;
        end

        function set.FontSize(hObj,newValue)
            hObj.TextComp.FontSize=newValue;
            hObj.MarkDirty('all');
        end

        function val=get.FontSizeMode(hObj)
            val=hObj.TextComp.FontSizeMode;
        end

        function set.FontSizeMode(hObj,newValue)
            hObj.TextComp.FontSizeMode=newValue;
            hObj.MarkDirty('all');
        end

        function val=get.FontSize_I(hObj)
            val=hObj.TextComp.FontSize_I;
        end

        function set.FontSize_I(hObj,newValue)
            hObj.TextComp.FontSize_I=newValue;
            hObj.MarkDirty('all');
        end



        function val=get.FontWeight(hObj)
            val=hObj.TextComp.FontWeight;
        end

        function set.FontWeight(hObj,newValue)
            hObj.TextComp.FontWeight=newValue;
            hObj.MarkDirty('all');
        end

        function val=get.FontWeightMode(hObj)
            val=hObj.TextComp.FontWeightMode;
        end

        function set.FontWeightMode(hObj,newValue)
            hObj.TextComp.FontWeightMode=newValue;
            hObj.MarkDirty('all');
        end

        function val=get.FontWeight_I(hObj)
            val=hObj.TextComp.FontWeight_I;
        end

        function set.FontWeight_I(hObj,newValue)
            hObj.TextComp.FontWeight_I=newValue;
            hObj.MarkDirty('all');
        end



        function val=get.Interpreter(hObj)
            val=hObj.TextComp.Interpreter;
        end

        function set.Interpreter(hObj,newValue)
            hObj.TextComp.Interpreter=newValue;
            hObj.MarkDirty('all');
        end

        function val=get.InterpreterMode(hObj)
            val=hObj.TextComp.InterpreterMode;
        end

        function set.InterpreterMode(hObj,newValue)
            hObj.TextComp.InterpreterMode=newValue;
            hObj.MarkDirty('all');
        end

        function val=get.Interpreter_I(hObj)
            val=hObj.TextComp.Interpreter_I;
        end

        function set.Interpreter_I(hObj,newValue)
            hObj.TextComp.Interpreter_I=newValue;
            hObj.MarkDirty('all');
        end


        function set.Position(hObj,newValue)
            hObj.Position=newValue;
            hObj.MarkDirty('all');
        end

        function set.TextComp(hObj,newValue)
            delete(hObj.TextComp);
            if~isempty(newValue)
                hObj.addNode(newValue);
            end
            hObj.TextComp=newValue;
            hObj.MarkDirty('all');
        end

        function val=get.Editing(hObj)
            val=hObj.TextComp.Editing;
        end

        function set.Editing(hObj,newValue)
            hObj.TextComp.Editing=newValue;
            hObj.MarkDirty('all');
        end

        function hObj=Text(varargin)
            doSetup(hObj);
            if nargin==1
                hObj.String=varargin{1};
            end
        end
    end

    methods(Hidden=true)
        function doUpdate(hObj,updateState)%#ok<INUSD>


            if isempty(hObj.TextComp)||~isvalid(hObj.TextComp)
                doSetup(hObj);
            end



            if strcmp(hObj.TextComp.HorizontalAlignmentMode,'auto')
                hObj.TextComp.HorizontalAlignment_I=hObj.HorizontalAlignment;
            end
            if strcmp(hObj.TextComp.PositionMode,'auto')
                hObj.TextComp.Position_I=hObj.Position;
            end
        end

        function hParent=getParentImpl(~,hParent)


            if isscalar(hParent)
                hLegend=ancestor(hParent,'matlab.graphics.illustration.Legend','node');
                if isscalar(hLegend)
                    hParent=hLegend;
                end
            end
        end

        function jObj=java(hObj)







            jObj=java(hObj.TextComp);
        end
    end

    methods(Access='protected',Hidden=true)
        function pg=getPropertyGroups(~)
            pg=matlab.mixin.util.PropertyGroup(...
            {'String','FontSize','FontWeight','FontName','Color','Interpreter'});
        end

        function str=getDescriptiveLabelForDisplay(hObj)
            str=hObj.String;
        end
    end

    methods(Access=private)
        function doSetup(hObj)
            hObj.HitTest='off';
            hObj.Serializable='off';






            hObj.TextComp=matlab.graphics.primitive.Text;
            hObj.TextComp.Units='data';
            hObj.TextComp.HitTest='off';
            hObj.TextComp.VerticalAlignment='middle';
            hObj.TextComp.SelectionHighlight='off';
            hObj.TextComp.Interruptible='off';
            hObj.TextComp.FontUnits='points';



            hObj.TextComp.Internal=true;




            addlistener(hObj.TextComp,'String','PostSet',@(h,e)hObj.MarkDirty('all'));
        end
    end
end
