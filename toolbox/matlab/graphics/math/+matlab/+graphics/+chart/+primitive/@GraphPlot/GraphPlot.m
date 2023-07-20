classdef(ConstructOnLoad,Sealed)GraphPlot<matlab.graphics.primitive.Data...
    &matlab.graphics.mixin.Legendable&matlab.graphics.mixin.AxesParentable...
    &matlab.graphics.mixin.Selectable&matlab.graphics.chart.interaction.DataAnnotatable...
    &matlab.graphics.internal.Legacy











    properties(Dependent,Access=public)











        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBMatrixFlatNoneColor;





        EdgeCData;







        EdgeLabel={};







        EdgeLabelColor matlab.internal.datatype.matlab.graphics.datatype.RGBMatrixColor=[0,0,0];





        EdgeFontSize=8;




        EdgeFontName matlab.internal.datatype.matlab.graphics.datatype.FontName='Helvetica';






        EdgeFontAngle matlab.internal.datatype.matlab.graphics.datatype.FontAngleArray='italic';






        EdgeFontWeight matlab.internal.datatype.matlab.graphics.datatype.FontWeightArray='normal';





        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyleArray='-';






        LineWidth=0.5;








        ArrowSize=7;









        ArrowPosition=0.5;





        ShowArrows matlab.internal.datatype.matlab.graphics.datatype.on_off='off';












        NodeColor matlab.internal.datatype.matlab.graphics.datatype.RGBMatrixFlatNoneColor;





        NodeCData;








        NodeLabel={};







        NodeLabelColor matlab.internal.datatype.matlab.graphics.datatype.RGBMatrixColor=[0,0,0];





        NodeFontSize=8;




        NodeFontName matlab.internal.datatype.matlab.graphics.datatype.FontName='Helvetica';






        NodeFontAngle matlab.internal.datatype.matlab.graphics.datatype.FontAngleArray='normal';






        NodeFontWeight matlab.internal.datatype.matlab.graphics.datatype.FontWeightArray='normal';







        Interpreter matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter='tex';





        Marker matlab.internal.datatype.matlab.graphics.datatype.MarkerStyleArray='o';







        MarkerSize=4;




        XData;




        YData;




        ZData;
    end

    properties(Dependent,Access=public,AbortSet,NeverAmbiguous)







        EdgeLabelMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='manual';









        NodeLabelMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='manual';
    end

    properties




        EdgeAlpha=0.5;
    end

    properties(Hidden)

        EdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBMatrixFlatNoneColor=[0,0,0];
        EdgeCData_I=[];
        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyleArray='-';
        LineWidth_I=0.5;

        EdgeLabel_I cell{matlab.internal.validation.mustBeVector(EdgeLabel_I)}={};
        EdgeLabelColor_I=[0,0,0];
        EdgeFontSize_I=8;
        EdgeFontName_I='Helvetica';
        isEdgeFontItalic_I=true;
        isEdgeFontBold_I=false;

        ArrowSize_I=7;
        ArrowPosition_I=0.5;
        ShowArrows_I matlab.internal.datatype.matlab.graphics.datatype.on_off='off';

        NodeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBMatrixFlatNoneColor=[0,0,0];
        NodeCData_I=[];
        MarkerSize_I=4;
        Marker_I matlab.internal.datatype.matlab.graphics.datatype.MarkerStyleArray='o';

        NodeLabel_I cell{matlab.internal.validation.mustBeVector(NodeLabel_I)}={};
        NodeLabelColor_I=[0,0,0];
        NodeFontSize_I=8;
        NodeFontName_I='Helvetica';
        isNodeFontItalic_I=false;
        isNodeFontBold_I=false;

        XData_I double{matlab.internal.validation.mustBeVector(XData_I)}=zeros(1,0);
        YData_I double{matlab.internal.validation.mustBeVector(YData_I)}=zeros(1,0);
        ZData_I double{matlab.internal.validation.mustBeVector(ZData_I)}=zeros(1,0);
        Interpreter_I='tex';
    end

    properties(Hidden,NeverAmbiguous)
        EdgeLabelMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual='manual';
        NodeLabelMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual='manual';
    end

    properties(Access=private)
        EdgeCoords_ double{matlab.internal.validation.mustBeMatrix(EdgeCoords_)}=zeros(0,3);
        EdgeCoordsIndex_ double{matlab.internal.validation.mustBeVector(EdgeCoordsIndex_)}=zeros(0,1);
        Layout_ char='auto';
        LayoutParameters_ cell={};
        wasReset_ logical=true;


        BasicGraph_=matlab.internal.graph.MLGraph;
        EdgeWeights_=zeros(0,1);
        CirclePerm_ double{matlab.internal.validation.mustBeVector(CirclePerm_)}=[];
        NodeNames_ cell{matlab.internal.validation.mustBeVector(NodeNames_)}={};
        IsDirected_(1,1)logical=false;
        MarkerHandlesArrayIndex_ double{matlab.internal.validation.mustBeVector(MarkerHandlesArrayIndex_)}=zeros(0,1);
        EdgeLineHandlesArrayIndex_ double{matlab.internal.validation.mustBeVector(EdgeLineHandlesArrayIndex_)}=zeros(0,1);
    end

    properties(Access=private,Constant)
        LargeGraphThreshold_=100;
    end

    properties(Access=private,Transient)

        EdgeLineHandles_ matlab.graphics.primitive.world.LineStrip{matlab.internal.validation.mustBeVector(EdgeLineHandles_)};
        EdgeLabelHandles_ matlab.graphics.primitive.world.Text{matlab.internal.validation.mustBeVector(EdgeLabelHandles_)};
        EdgeArrowHandles_ matlab.graphics.primitive.world.TriangleStrip;

        MarkerHandles_{matlab.internal.validation.mustBeVector(MarkerHandles_)};
        NodeLabelHandles_ matlab.graphics.primitive.world.Text{matlab.internal.validation.mustBeVector(NodeLabelHandles_)};
        NodeLabelHandlesArrayIndex_ double{matlab.internal.validation.mustBeVector(NodeLabelHandlesArrayIndex_)}=zeros(0,1);
    end

    properties(Transient,DeepCopy,SetAccess=private,GetAccess=?graphicstest.mixins.Selectable)
        SelectionHandle{mustBe_matlab_mixin_Heterogeneous};
    end




    methods

        function hObj=GraphPlot(varargin)
            addDependencyConsumed(hObj,{'figurecolormap','colorspace',...
            'dataspace','xyzdatalimits','ref_frame','view','hgtransform_under_dataspace'});

            if rem(length(varargin),2)~=0
                error(message('MATLAB:graphfun:plot:ArgNameValueMismatch'));
            end




            hObj.wasReset_=false;


            varargin=extractInputNameValue(hObj,varargin,'BasicGraph','BasicGraph_');
            if isa(hObj.BasicGraph_,'matlab.internal.graph.MLGraph')
                hObj.IsDirected_=false;
            else
                hObj.IsDirected_=true;
                hObj.ShowArrows_I='on';
            end


            varargin=extractInputNameValue(hObj,varargin,'NodeNames','NodeNames_');
            varargin=extractInputNameValue(hObj,varargin,'EdgeWeights','EdgeWeights_');


            setInteractionHint(hObj,'DataBrushing',false);


            hObj.EdgeLineHandles_=matlab.graphics.primitive.world.LineStrip('Internal',true);
            hObj.EdgeLineHandlesArrayIndex_=ones(1,numedges(hObj.BasicGraph_));
            hObj.EdgeArrowHandles_=matlab.graphics.primitive.world.TriangleStrip('Internal',true);
            updateEdgeLineHandles(hObj);
            hObj.MarkerHandles_=matlab.graphics.primitive.world.Marker('Style','circle','Internal',true);
            hObj.MarkerHandlesArrayIndex_=ones(1,numnodes(hObj.BasicGraph_));
            updateMarkerHandles(hObj);


            if numnodes(hObj.BasicGraph_)<=hObj.LargeGraphThreshold_
                hObj.NodeLabelMode='auto';
            end

            if numnodes(hObj.BasicGraph_)>hObj.LargeGraphThreshold_
                hObj.MarkerSize=2;
                if hObj.IsDirected_
                    hObj.ArrowSize=4;
                end
            end


            varargin=extractInputNameValue(hObj,varargin,'AutoColor','NodeColor');
            hObj.EdgeColor=hObj.NodeColor;


            varargin=extractInputNameValue(hObj,varargin,'Parent');




            try
                hObj.XData_I=zeros(1,numnodes(hObj.BasicGraph_));
                hObj.YData_I=zeros(1,numnodes(hObj.BasicGraph_));
                hObj.ZData_I=zeros(1,numnodes(hObj.BasicGraph_));
                layoutindex=(find(strcmp(varargin(1:2:end),'Layout'))-1)*2+1;
                xindex=(find(strcmp(varargin(1:2:end),'XData'))-1)*2+1;
                yindex=(find(strcmp(varargin(1:2:end),'YData'))-1)*2+1;
                zindex=(find(strcmp(varargin(1:2:end),'ZData'))-1)*2+1;
                layoutParams={'Iterations','XStart','YStart','ZStart',...
                'WeightEffect','UseGravity','Center','Direction',...
                'Sources','Sinks','AssignLayers','Dimension'};
                if isempty(xindex)&&isempty(yindex)&&isempty(zindex)
                    if isempty(layoutindex)
                        layout(hObj);
                    else

                        for i=1:length(layoutindex)
                            layoutmethod=validatestring(varargin{layoutindex(i)+1},...
                            {'auto','circle','force','layered','subspace','subspace3','force3'});
                        end
                        layoutoptions=find(ismember(varargin(1:2:end),layoutParams));

                        layoutoptions=reshape((layoutoptions-1)*2+1,1,[]);
                        layoutoptions=repelem(layoutoptions,2);
                        layoutoptions(2:2:end)=layoutoptions(2:2:end)+1;

                        layout(hObj,layoutmethod,varargin{layoutoptions});
                        varargin([layoutindex,layoutindex+1,layoutoptions])=[];
                    end
                elseif~isempty(xindex)&&~isempty(yindex)&&isempty(layoutindex)
                    for i=1:length(xindex)
                        hObj.XData=varargin{xindex(i)+1};
                    end
                    for i=1:length(yindex)
                        hObj.YData=varargin{yindex(i)+1};
                    end
                    if~isempty(zindex)
                        for i=1:length(zindex)
                            hObj.ZData=varargin{zindex(i)+1};
                        end
                    end
                    varargin([xindex,xindex+1,yindex,yindex+1,zindex,zindex+1])=[];
                else
                    if~isempty(layoutindex)
                        error(message('MATLAB:graphfun:plot:LayoutWithXDataAndYData'));
                    elseif isempty(zindex)
                        error(message('MATLAB:graphfun:plot:MissingXDataOrYData'));
                    else
                        error(message('MATLAB:graphfun:plot:ZDataWithoutXDataAndYData'));
                    end
                end
            catch e
                layout(hObj);
                rethrow(e);
            end















            if any(ismember(varargin(1:2:end),layoutParams))
                layoutoptions=find(ismember(varargin(1:2:end),layoutParams));
                layoutoptions=2*layoutoptions-1;
                error(message('MATLAB:graphfun:plot:LayoutOptsWithoutLayout',varargin{layoutoptions(1)}));
            end


            for i=1:2:length(varargin)
                set(hObj,varargin{i},varargin{i+1});
            end




            if isunix
                d=opengl('data');
                if d.Software&&~isempty(hObj.Parent)
                    ax=hObj.Parent;
                    if~ishghandle(ax,'axes')
                        ax=ancestor(ax,'axes');
                    end
                    if isa(ax,'matlab.graphics.axis.Axes')
                        set(get(ax,'Camera'),'TransparencyMethodHint','objectsort');
                    end
                end
            end
        end





        function set.BasicGraph_(hObj,basicgraph)
            if~(isa(basicgraph,'matlab.internal.graph.MLGraph')||...
                isa(basicgraph,'matlab.internal.graph.MLDigraph'))
                error(message('MATLAB:graphfun:plot:InvalidBasicGraph'));
            end
            hObj.BasicGraph_=basicgraph;
        end


        function x=get.XData(hObj)
            x=hObj.XData_I;
        end

        function set.XData(hObj,x)

            validateattributes(x,{'numeric'},{'real','vector','finite',...
            'numel',numnodes(hObj.BasicGraph_)},class(hObj),'XData');
            x=full(double(x));
            hObj.XData_I=reshape(x,1,[]);
            [hObj.EdgeCoords_,hObj.EdgeCoordsIndex_]=updateEdgeCoords(hObj);
            hObj.MarkDirty('all');
            hObj.Layout_='manual';
            hObj.LayoutParameters_={};
            hObj.sendDataChangedEvent();
        end

        function y=get.YData(hObj)
            y=hObj.YData_I;
        end

        function set.YData(hObj,y)

            validateattributes(y,{'numeric'},{'real','vector','finite',...
            'numel',numnodes(hObj.BasicGraph_)},class(hObj),'YData');
            y=full(double(y));
            hObj.YData_I=reshape(y,1,[]);
            [hObj.EdgeCoords_,hObj.EdgeCoordsIndex_]=updateEdgeCoords(hObj);
            hObj.MarkDirty('all');
            hObj.Layout_='manual';
            hObj.LayoutParameters_={};
            hObj.sendDataChangedEvent();
        end

        function z=get.ZData(hObj)
            z=hObj.ZData_I;
        end

        function set.ZData(hObj,z)

            validateattributes(z,{'numeric'},{'real','vector','finite',...
            'numel',numnodes(hObj.BasicGraph_)},class(hObj),'ZData');
            z=full(double(z));
            hObj.ZData_I=reshape(z,1,[]);
            [hObj.EdgeCoords_,hObj.EdgeCoordsIndex_]=updateEdgeCoords(hObj);
            hObj.MarkDirty('all');
            hObj.Layout_='manual';
            hObj.LayoutParameters_={};
            hObj.sendDataChangedEvent();
        end


        function ec=get.EdgeColor(hObj)
            ec=hObj.EdgeColor_I;
        end

        function set.EdgeColor(hObj,ec)
            if isnumeric(ec)&&~isrow(ec)&&size(ec,1)~=numedges(hObj.BasicGraph_)
                error(message('MATLAB:graphfun:plot:InvalidEdgeColor',numedges(hObj.BasicGraph_)));
            elseif strcmp(ec,'flat')&&isempty(hObj.EdgeCData_I)
                error(message('MATLAB:graphfun:plot:UninitializedEdgeCData'));
            end
            hObj.EdgeColor_I=ec;
            hObj.MarkDirty('all');
        end

        function ec=get.EdgeCData(hObj)
            ec=hObj.EdgeCData_I;
        end

        function set.EdgeCData(hObj,ec)
            nrEdges=numedges(hObj.BasicGraph_);
            validateattributes(ec,{'numeric','logical'},{'vector','real','numel',nrEdges},...
            class(hObj),'EdgeCData');

            hObj.EdgeCData_I=reshape(ec,1,[]);
            hObj.EdgeColor_I='flat';

            hObj.MarkDirty('all');
        end


        function nc=get.NodeColor(hObj)
            nc=hObj.NodeColor_I;
        end

        function set.NodeColor(hObj,nc)
            if isnumeric(nc)&&~isrow(nc)&&size(nc,1)~=numnodes(hObj.BasicGraph_)
                error(message('MATLAB:graphfun:plot:InvalidNodeColor',numnodes(hObj.BasicGraph_)));
            elseif strcmp(nc,'flat')&&isempty(hObj.NodeCData_I)
                error(message('MATLAB:graphfun:plot:UninitializedNodeCData'));
            end
            hObj.NodeColor_I=nc;
            hObj.MarkDirty('all');
        end

        function nc=get.NodeCData(hObj)
            nc=hObj.NodeCData_I;
        end

        function set.NodeCData(hObj,nc)
            nrNodes=numnodes(hObj.BasicGraph_);
            validateattributes(nc,{'numeric','logical'},{'vector','real','numel',nrNodes},...
            class(hObj),'NodeCData');

            hObj.NodeCData_I=reshape(nc,1,[]);
            hObj.NodeColor_I='flat';

            hObj.MarkDirty('all');
        end


        function el=get.EdgeLabel(hObj)
            el=hObj.EdgeLabel_I;
        end

        function set.EdgeLabel(hObj,s)
            if numel(s)==numedges(hObj.BasicGraph_)&&isvector(s)
                if isstring(s)
                    s=cellstr(s);
                end
                if iscellstr(s)
                    label=reshape(s,1,[]);
                elseif isnumeric(s)
                    label=hObj.num2labels(s);
                else
                    error(message('MATLAB:graphfun:plot:InvalidEdgeLabel'));
                end
            elseif isempty(s)
                label={};
            else
                error(message('MATLAB:graphfun:plot:ScalarOrVectorOfLength','EdgeLabel',numedges(hObj.BasicGraph_)));
            end
            hObj.EdgeLabel_I=label;
            hObj.EdgeLabelMode_I='manual';

            updateEdgeLabelHandles(hObj);
            hObj.MarkDirty('all');
        end

        function el=get.EdgeLabelMode(hObj)
            el=hObj.EdgeLabelMode_I;
        end

        function set.EdgeLabelMode(hObj,s)
            hObj.EdgeLabelMode_I=s;
            if strcmp(s,'auto')

                if isempty(hObj.EdgeWeights_)
                    w=1:numedges(hObj.BasicGraph_);
                else
                    w=hObj.EdgeWeights_;
                end

                hObj.EdgeLabel_I=hObj.num2labels(w);

                updateEdgeLabelHandles(hObj);
                hObj.MarkDirty('all');
            end
        end


        function nc=get.EdgeLabelColor(hObj)
            nc=hObj.EdgeLabelColor_I;
        end

        function set.EdgeLabelColor(hObj,nc)
            if~isrow(nc)&&size(nc,1)~=numedges(hObj.BasicGraph_)
                error(message('MATLAB:graphfun:plot:InvalidEdgeLabelColor',numedges(hObj.BasicGraph_)));
            end
            hObj.EdgeLabelColor_I=nc;
            hObj.MarkDirty('all');
        end


        function nfs=get.EdgeFontSize(hObj)
            nfs=hObj.EdgeFontSize_I;
        end

        function set.EdgeFontSize(hObj,nfs)
            validateattributes(nfs,{'numeric'},{'vector','positive','finite','real'},...
            class(hObj),'EdgeFontSize');
            nrEdges=numedges(hObj.BasicGraph_);
            if~isscalar(nfs)&&numel(nfs)~=nrEdges
                error(message('MATLAB:graphfun:plot:ScalarOrVectorOfLength','EdgeFontSize',nrEdges));
            end
            hObj.EdgeFontSize_I=full(double(reshape(nfs,1,[])));
            hObj.MarkDirty('all');
        end


        function nfn=get.EdgeFontName(hObj)
            nfn=hObj.EdgeFontName_I;
        end

        function set.EdgeFontName(hObj,nfn)



            hObj.EdgeFontName_I=nfn;
            hObj.MarkDirty('all');
        end


        function nfa=get.EdgeFontAngle(hObj)
            names={'normal','italic'};
            nfa=names(hObj.isEdgeFontItalic_I+1);
            if isscalar(nfa)
                nfa=nfa{1};
            end
        end

        function set.EdgeFontAngle(hObj,nfa)
            [~,isItalic]=ismember(nfa,{'normal','italic'});
            isItalic=reshape(isItalic==2,1,[]);
            if~isscalar(isItalic)&&length(isItalic)~=numedges(hObj.BasicGraph_)
                error(message('MATLAB:graphfun:plot:InvalidEdgeFontAngle'));
            end
            hObj.isEdgeFontItalic_I=isItalic;
            hObj.MarkDirty('all');
        end


        function nfw=get.EdgeFontWeight(hObj)
            names={'normal','bold'};
            nfw=names(hObj.isEdgeFontBold_I+1);
            if isscalar(nfw)
                nfw=nfw{1};
            end
        end

        function set.EdgeFontWeight(hObj,nfw)
            [~,isBold]=ismember(nfw,{'normal','bold'});
            if~isscalar(isBold)&&length(isBold)~=numedges(hObj.BasicGraph_)
                error(message('MATLAB:graphfun:plot:InvalidEdgeFontWeight'));
            end
            isBold=reshape(isBold==2,1,[]);
            hObj.isEdgeFontBold_I=isBold;
            hObj.MarkDirty('all');
        end


        function nl=get.NodeLabel(hObj)
            nl=hObj.NodeLabel_I;
        end

        function set.NodeLabel(hObj,s)
            if numel(s)==numnodes(hObj.BasicGraph_)&&isvector(s)
                if isstring(s)
                    s=cellstr(s);
                end
                if iscellstr(s)
                    label=reshape(s,1,[]);
                elseif isnumeric(s)
                    label=hObj.num2labels(s);
                else
                    error(message('MATLAB:graphfun:plot:InvalidNodeLabel'));
                end
            elseif isempty(s)
                label={};
            else
                error(message('MATLAB:graphfun:plot:ScalarOrVectorOfLength','NodeLabel',numnodes(hObj.BasicGraph_)));
            end
            hObj.NodeLabel_I=label;
            hObj.NodeLabelMode_I='manual';

            updateNodeLabelHandles(hObj);
            hObj.MarkDirty('all');
        end

        function nl=get.NodeLabelMode(hObj)
            nl=hObj.NodeLabelMode_I;
        end

        function set.NodeLabelMode(hObj,s)
            hObj.NodeLabelMode_I=s;
            if strcmp(s,'auto')

                if isempty(hObj.NodeNames_)
                    names=hObj.num2labels(1:numnodes(hObj.BasicGraph_));
                else
                    names=reshape(hObj.NodeNames_,1,[]);
                end
                hObj.NodeLabel_I=names;
                updateNodeLabelHandles(hObj);
                hObj.MarkDirty('all');
            end
        end


        function nc=get.NodeLabelColor(hObj)
            nc=hObj.NodeLabelColor_I;
        end

        function set.NodeLabelColor(hObj,nc)
            if~isrow(nc)&&size(nc,1)~=numnodes(hObj.BasicGraph_)
                error(message('MATLAB:graphfun:plot:InvalidNodeLabelColor',numnodes(hObj.BasicGraph_)));
            end
            hObj.NodeLabelColor_I=nc;
            updateNodeLabelHandles(hObj);
            hObj.MarkDirty('all');
        end


        function nfs=get.NodeFontSize(hObj)
            nfs=hObj.NodeFontSize_I;
        end

        function set.NodeFontSize(hObj,nfs)
            validateattributes(nfs,{'numeric'},{'vector','positive','finite','real'},...
            class(hObj),'NodeFontSize');
            nrNodes=numnodes(hObj.BasicGraph_);
            if~isscalar(nfs)&&numel(nfs)~=nrNodes
                error(message('MATLAB:graphfun:plot:ScalarOrVectorOfLength','NodeFontSize',nrNodes));
            end
            hObj.NodeFontSize_I=full(double(reshape(nfs,1,[])));
            updateNodeLabelHandles(hObj);
            hObj.MarkDirty('all');
        end


        function nfn=get.NodeFontName(hObj)
            nfn=hObj.NodeFontName_I;
        end

        function set.NodeFontName(hObj,nfn)



            hObj.NodeFontName_I=nfn;
            hObj.MarkDirty('all');
        end


        function nfa=get.NodeFontAngle(hObj)
            names={'normal','italic'};
            nfa=names(hObj.isNodeFontItalic_I+1);
            if isscalar(nfa)
                nfa=nfa{1};
            end
        end

        function set.NodeFontAngle(hObj,nfa)
            [~,isItalic]=ismember(nfa,{'normal','italic'});
            if~isscalar(isItalic)&&length(isItalic)~=numnodes(hObj.BasicGraph_)
                error(message('MATLAB:graphfun:plot:InvalidNodeFontAngle'));
            end
            isItalic=reshape(isItalic==2,1,[]);
            hObj.isNodeFontItalic_I=isItalic;
            updateNodeLabelHandles(hObj);
            hObj.MarkDirty('all');
        end


        function nfw=get.NodeFontWeight(hObj)
            names={'normal','bold'};
            nfw=names(hObj.isNodeFontBold_I+1);
            if isscalar(nfw)
                nfw=nfw{1};
            end
        end

        function set.NodeFontWeight(hObj,nfw)
            [~,isBold]=ismember(nfw,{'normal','bold'});
            if~isscalar(isBold)&&length(isBold)~=numnodes(hObj.BasicGraph_)
                error(message('MATLAB:graphfun:plot:InvalidNodeFontWeight'));
            end
            isBold=reshape(isBold==2,1,[]);
            hObj.isNodeFontBold_I=isBold;
            updateNodeLabelHandles(hObj);
            hObj.MarkDirty('all');
        end


        function in=get.Interpreter(hObj)
            in=hObj.Interpreter_I;
        end

        function set.Interpreter(hObj,in)
            hObj.Interpreter_I=in;
            hObj.MarkDirty('all');
        end


        function es=get.LineStyle(hObj)
            es=hObj.LineStyle_I;
        end

        function set.LineStyle(hObj,es)
            if~ischar(es)
                nrEdges=numedges(hObj.BasicGraph_);
                if length(es)~=nrEdges
                    error(message('MATLAB:graphfun:plot:ScalarOrVectorOfLength','LineStyle',nrEdges));
                end
                es=reshape(es,1,[]);
            end
            hObj.LineStyle_I=es;
            updateEdgeLineHandles(hObj);
            hObj.MarkDirty('all');
        end

        function set.EdgeAlpha(hObj,ea)
            validateattributes(ea,{'double','single'},...
            {'scalar','real','nonnegative','<=',1},class(hObj),...
            'EdgeAlpha');
            hObj.EdgeAlpha=full(ea);
            hObj.MarkDirty('all');
        end


        function nm=get.Marker(hObj)
            nm=hObj.Marker_I;
        end

        function set.Marker(hObj,nm)
            if~ischar(nm)

                nrNodes=numnodes(hObj.BasicGraph_);
                if numel(nm)~=nrNodes
                    error(message('MATLAB:graphfun:plot:ScalarOrVectorOfLength','Marker',nrNodes));
                end
                nm=reshape(nm,1,[]);
            end
            hObj.Marker_I=nm;
            updateMarkerHandles(hObj);
            hObj.MarkDirty('all');
        end


        function ew=get.LineWidth(hObj)
            ew=hObj.LineWidth_I;
        end

        function set.LineWidth(hObj,ew)
            validateattributes(ew,{'numeric'},{'vector','positive','finite','real'},...
            class(hObj),'LineWidth');
            nrEdges=numedges(hObj.BasicGraph_);
            if~(isscalar(ew)||numel(ew)==nrEdges)
                error(message('MATLAB:graphfun:plot:ScalarOrVectorOfLength','LineWidth',nrEdges));
            end
            hObj.LineWidth_I=full(double(reshape(ew,1,[])));
            updateEdgeLineHandles(hObj);
            hObj.MarkDirty('all');
        end


        function nms=get.MarkerSize(hObj)
            nms=hObj.MarkerSize_I;
        end

        function set.MarkerSize(hObj,nms)
            validateattributes(nms,{'numeric'},{'vector','positive','finite','real'},...
            class(hObj),'MarkerSize');
            nrNodes=numnodes(hObj.BasicGraph_);
            if~(isscalar(nms)||numel(nms)==nrNodes)
                error(message('MATLAB:graphfun:plot:ScalarOrVectorOfLength','MarkerSize',nrNodes));
            end
            hObj.MarkerSize_I=full(double(reshape(nms,1,[])));
            updateMarkerHandles(hObj);
            hObj.MarkDirty('all');
        end


        function as=get.ArrowSize(hObj)
            as=hObj.ArrowSize_I;
        end

        function set.ArrowSize(hObj,as)
            if~hObj.IsDirected_
                error(message('MATLAB:graphfun:plot:ArrowSizeDigraphOnly'));
            end
            validateattributes(as,{'numeric'},{'vector','nonnegative','finite','real'},...
            class(hObj),'ArrowSize');
            nrEdges=numedges(hObj.BasicGraph_);
            if~(isscalar(as)||numel(as)==nrEdges)
                error(message('MATLAB:graphfun:plot:ScalarOrVectorOfLength','ArrowSize',nrEdges));
            end
            hObj.ArrowSize_I=full(double(reshape(as,1,[])));
            hObj.MarkDirty('all');
        end


        function as=get.ArrowPosition(hObj)
            as=hObj.ArrowPosition_I;
        end

        function set.ArrowPosition(hObj,ap)
            if~hObj.IsDirected_
                error(message('MATLAB:graphfun:plot:ArrowPositionDigraphOnly'));
            end
            validateattributes(ap,{'numeric'},{'vector','<=',1,'>=',0,'real'},...
            class(hObj),'ArrowPosition');
            nrEdges=numedges(hObj.BasicGraph_);
            if~(isscalar(ap)||numel(ap)==nrEdges)
                error(message('MATLAB:graphfun:plot:ScalarOrVectorOfLength','ArrowPosition',nrEdges));
            end
            hObj.ArrowPosition_I=full(double(reshape(ap,1,[])));
            hObj.MarkDirty('all');
        end


        function as=get.ShowArrows(hObj)
            as=hObj.ShowArrows_I;
        end

        function set.ShowArrows(hObj,sa)
            if~hObj.IsDirected_&&strcmp(sa,'on')
                error(message('MATLAB:graphfun:plot:ShowArrowsDigraphOnly'));
            end
            hObj.ShowArrows_I=sa;
            hObj.MarkDirty('all');
        end

        function set.Layout_(hObj,lay)
            hObj.Layout_=lay;
            updateNodeLabelHandles(hObj);
        end


        function set.EdgeLineHandles_(hObj,hEdgeLine)
            if isempty(hEdgeLine)||isempty(hEdgeLine(1).Parent)
                hObj.EdgeLineHandles_=hEdgeLine;
            else

                hObj.EdgeLineHandles_=reshape(copy(hEdgeLine),...
                size(hEdgeLine));
            end
            for i=1:length(hObj.EdgeLineHandles_)
                hObj.addNode(hObj.EdgeLineHandles_(i));
            end
        end

        function set.EdgeLabelHandles_(hObj,hEdgeLabel)
            if isempty(hEdgeLabel)||isempty(hEdgeLabel(1).Parent)
                hObj.EdgeLabelHandles_=hEdgeLabel;
            else

                hObj.EdgeLabelHandles_=reshape(copy(hEdgeLabel),...
                size(hEdgeLabel));
            end
            for i=1:length(hObj.EdgeLabelHandles_)
                hObj.addNode(hObj.EdgeLabelHandles_(i));
            end
        end

        function set.EdgeArrowHandles_(hObj,hEdgeArrow)
            if isempty(hEdgeArrow)||isempty(hEdgeArrow(1).Parent)
                hObj.EdgeArrowHandles_=hEdgeArrow;
            else

                hObj.EdgeArrowHandles_=reshape(copy(hEdgeArrow),...
                size(hEdgeArrow));
            end
            hObj.addNode(hObj.EdgeArrowHandles_);
        end

        function set.MarkerHandles_(hObj,hMarker)
            if isempty(hMarker)||isempty(hMarker(1).Parent)
                hObj.MarkerHandles_=hMarker;
            else

                hObj.MarkerHandles_=reshape(copy(hMarker),...
                size(hMarker));
            end
            for i=1:length(hObj.MarkerHandles_)
                hObj.addNode(hObj.MarkerHandles_(i));
            end
        end

        function set.NodeLabelHandles_(hObj,hNodeLabel)
            if isempty(hNodeLabel)||isempty(hNodeLabel(1).Parent)
                hObj.NodeLabelHandles_=hNodeLabel;
            else

                hObj.NodeLabelHandles_=reshape(copy(hNodeLabel),...
                size(hNodeLabel));
            end
            for i=1:length(hObj.NodeLabelHandles_)
                hObj.addNode(hObj.NodeLabelHandles_(i));
            end
        end

        function set.SelectionHandle(hObj,hsel)
            hObj.SelectionHandle=hsel;
            if~isempty(hObj.SelectionHandle)
                hObj.addNode(hObj.SelectionHandle);


                hObj.SelectionHandle.Description='GraphPlot SelectionHandle';
            end
        end


        layout(hObj,varargin)

        highlight(hObj,part,varargin)

        labelnode(hObj,nodes,labels)

        labeledge(hObj,t,h,labels)
    end

    methods(Hidden)

        function ex=getXYZDataExtents(hObj)

            xdata=[hObj.XData_I,hObj.EdgeCoords_(:,1).'];
            ydata=[hObj.YData_I,hObj.EdgeCoords_(:,2).'];
            zdata=[hObj.ZData_I,hObj.EdgeCoords_(:,3).'];


            xmargin=(max(xdata)-min(xdata))*0.1;
            ymargin=(max(ydata)-min(ydata))*0.1;
            zmargin=(max(zdata)-min(zdata))*0.1;

            x=matlab.graphics.chart.primitive.utilities.arraytolimits(...
            [xdata,min(xdata)-xmargin,max(xdata)+xmargin]);
            y=matlab.graphics.chart.primitive.utilities.arraytolimits(...
            [ydata,min(ydata)-ymargin,max(ydata)+ymargin]);
            z=matlab.graphics.chart.primitive.utilities.arraytolimits(...
            [zdata,min(zdata)-zmargin,max(zdata)+zmargin]);

            ex=[x;y;z];
        end

        function ex=getColorAlphaDataExtents(hObj)

            minC=NaN;
            maxC=NaN;

            if strcmp(hObj.NodeColor,'flat')
                zdata=hObj.NodeCData;
                zdata=zdata(isfinite(zdata));
                if~isempty(zdata)
                    minC=min(zdata);
                    maxC=max(zdata);
                end
            end

            if strcmp(hObj.EdgeColor,'flat')
                zdata=hObj.EdgeCData;
                zdata=zdata(isfinite(zdata));
                if~isempty(zdata)
                    minC=min(min(zdata),minC);
                    maxC=max(max(zdata),maxC);
                end
            end

            ex=[minC,maxC;NaN,NaN];
        end

        doUpdate(hObj,us)

        graphic=getLegendGraphic(hObj)

        function mcodeConstructor(this,code)


            setConstructorName(code,'plot');
            arg=codegen.codeargument('Name','g',...
            'IsParameter',true,'comment',...
            getString(message('MATLAB:specgraph:mcodeConstructor:CommentGraph')));
            addConstructorArgin(code,arg);

            isdirected=this.IsDirected_;
            islargegraph=numnodes(this.BasicGraph_)>this.LargeGraphThreshold_;


            propsToAdd={'NodeColor','EdgeColor'};
            propsToIgnore={};


            if isdirected
                propsToAdd=[propsToAdd,{'ShowArrows'}];
                if islargegraph
                    propsToAdd=[propsToAdd,{'ArrowSize'}];
                end
            else
                propsToIgnore=[propsToIgnore,{'ArrowSize'}];
            end
            if islargegraph
                propsToAdd=[propsToAdd,{'MarkerSize'}];
            end

            if strcmp(this.EdgeLabelMode,'auto')
                propsToIgnore=[propsToIgnore,{'EdgeLabel'}];
                propsToAdd=[propsToAdd,{'EdgeLabelMode'}];
            else
                propsToAdd=[propsToAdd,{'EdgeLabel'}];
            end
            if strcmp(this.NodeLabelMode,'auto')
                propsToIgnore=[propsToIgnore,{'NodeLabel'}];
                propsToAdd=[propsToAdd,{'NodeLabelMode'}];
            else
                propsToAdd=[propsToAdd,{'NodeLabel'}];
            end


            manuallayout=strcmp(this.Layout_,'manual');
            if~manuallayout
                propsToIgnore=[propsToIgnore,{'XData','YData','ZData'}];
            else
                if all(this.ZData==0)
                    markAsParameter(code,{'XData','YData'});
                    propsToIgnore=[propsToIgnore,{'ZData'}];
                else
                    markAsParameter(code,{'XData','YData','ZData'});
                end
            end

            addProperty(code,propsToAdd);
            ignoreProperty(code,propsToIgnore);


            generateDefaultPropValueSyntax(code);


            if~manuallayout
                layoutn=codegen.codeargument('Value','Layout');
                layoutv=codegen.codeargument('Value',this.Layout_);
                addConstructorArgin(code,[layoutn,layoutv]);
                for i=1:2:length(this.LayoutParameters_)
                    paramn=codegen.codeargument('Value',this.LayoutParameters_{i});
                    paramv=codegen.codeargument('Value',this.LayoutParameters_{i+1});
                    addConstructorArgin(code,[paramn,paramv]);
                end
            end
        end

        function names=getNodeNames(hObj)

            names=hObj.NodeNames_;
        end



        function dataTipRows=createDefaultDataTipRows(hObj)
            nodeStr=getString(message('MATLAB:graphfun:plot:Node'));
            dataTipRows=dataTipTextRow(nodeStr,'NodeData');
            if hObj.IsDirected_
                indegStr=getString(message('MATLAB:graphfun:plot:InDegree'));
                outdegStr=getString(message('MATLAB:graphfun:plot:OutDegree'));
                dataTipRows=[dataTipRows;...
                dataTipTextRow(indegStr,'InDegreeData');...
                dataTipTextRow(outdegStr,'OutDegreeData')];
            else
                degStr=getString(message('MATLAB:graphfun:plot:Degree'));
                dataTipRows=[dataTipRows;...
                dataTipTextRow(degStr,'DegreeData')];
            end
        end

        function coordinateData=createCoordinateData(hObj,valueSource,dataIndex,~)
            import matlab.graphics.chart.interaction.dataannotatable.internal.CoordinateData;
            coordinateData=CoordinateData.empty(0,1);

            switch(valueSource)
            case 'NodeData'
                if~isempty(hObj.NodeNames_)
                    coordinateData=CoordinateData('NodeData',hObj.NodeNames_(dataIndex));
                else
                    coordinateData=CoordinateData('NodeData',num2str(dataIndex));
                end
            case 'InDegreeData'
                coordinateData=CoordinateData('InDegreeData',indegree(hObj.BasicGraph_,dataIndex));
            case 'OutDegreeData'
                coordinateData=CoordinateData('OutDegreeData',outdegree(hObj.BasicGraph_,dataIndex));
            case 'DegreeData'
                coordinateData=CoordinateData('DegreeData',degree(hObj.BasicGraph_,dataIndex));
            end
        end


        function valueSources=getAllValidValueSources(hObj)
            valueSources="NodeData";
            if hObj.IsDirected_
                valueSources=[valueSources;"InDegreeData";"OutDegreeData"];
            else
                valueSources=[valueSources;"DegreeData"];
            end
        end
    end

    methods(Access=protected,Hidden)
        function group=getPropertyGroups(~)

            group=matlab.mixin.util.PropertyGroup({'NodeColor',...
            'MarkerSize',...
            'Marker',...
            'EdgeColor',...
            'LineWidth',...
            'LineStyle',...
            'NodeLabel',...
            'EdgeLabel',...
            'XData',...
            'YData',...
            'ZData'});
        end


        function descriptors=doGetDataDescriptors(hObj,index,~)
            nodeStr=getString(message('MATLAB:graphfun:plot:Node'));
            if~isempty(hObj.NodeNames_)
                descriptors=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(nodeStr,hObj.NodeNames_(index));
            else
                descriptors=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(nodeStr,num2str(index));
            end
            if hObj.IsDirected_
                indegStr=getString(message('MATLAB:graphfun:plot:InDegree'));
                outdegStr=getString(message('MATLAB:graphfun:plot:OutDegree'));
                indeg=indegree(hObj.BasicGraph_,index);
                outdeg=outdegree(hObj.BasicGraph_,index);
                descriptors=[descriptors...
                ,matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(indegStr,indeg)...
                ,matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(outdegStr,outdeg)];
            else
                degStr=getString(message('MATLAB:graphfun:plot:Degree'));
                deg=degree(hObj.BasicGraph_,index);
                descriptors=[descriptors...
                ,matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(degStr,deg)];
            end
        end

        function index=doGetNearestIndex(hObj,index)
            index=max(1,min(index,length(hObj.XData)));
        end

        function index=doGetNearestPoint(hObj,position)
            index=localGetNearestPoint(hObj,position,true);
        end

        function[index,interpolationFactor]=doGetInterpolatedPoint(hObj,position)
            index=doGetNearestPoint(hObj,position);
            interpolationFactor=0;
        end

        function[index,interpolationFactor]=doGetInterpolatedPointInDataUnits(hObj,position)






            index=localGetNearestPoint(hObj,position,false);
            interpolationFactor=0;
        end

        function[index,interpolationFactor]=doIncrementIndex(hObj,index,direction,~)
            switch hObj.Layout_
            case 'circle'
                if any(strcmp(direction,{'left','up'}))
                    index=mod(index,length(hObj.XData))+1;
                else
                    index=mod(index-2,length(hObj.XData))+1;
                end
            case 'layered'
                xcurr=hObj.XData(index);
                ycurr=hObj.YData(index);
                layereddir=findparamvalue(hObj.LayoutParameters_,...
                'Direction','down');
                switch layereddir
                case{'down','up'}
                    switch direction
                    case 'left'
                        index=hObj.moveDataCursorToSibling(...
                        hObj.XData,hObj.YData,xcurr,ycurr,index);
                    case 'right'
                        index=hObj.moveDataCursorToSibling(...
                        -hObj.XData,hObj.YData,-xcurr,ycurr,index);
                    case 'up'
                        index=hObj.moveDataCursorToNextLayer(...
                        hObj.XData,-hObj.YData,xcurr,-ycurr,index);
                    case 'down'
                        index=hObj.moveDataCursorToNextLayer(...
                        hObj.XData,hObj.YData,xcurr,ycurr,index);
                    end
                case{'left','right'}
                    switch direction
                    case 'left'
                        index=hObj.moveDataCursorToNextLayer(...
                        hObj.YData,hObj.XData,ycurr,xcurr,index);
                    case 'right'
                        index=hObj.moveDataCursorToNextLayer(...
                        hObj.YData,-hObj.XData,ycurr,-xcurr,index);
                    case 'up'
                        index=hObj.moveDataCursorToSibling(...
                        -hObj.YData,hObj.XData,-ycurr,xcurr,index);
                    case 'down'
                        index=hObj.moveDataCursorToSibling(...
                        hObj.YData,hObj.XData,ycurr,xcurr,index);
                    end
                end
            otherwise
                xcurr=hObj.XData(index);
                ycurr=hObj.YData(index);
                zcurr=hObj.ZData(index);
                switch direction
                case 'left'
                    candidatenodes=find(hObj.XData<xcurr);
                case 'right'
                    candidatenodes=find(hObj.XData>xcurr);
                case 'up'
                    candidatenodes=find(hObj.YData>ycurr);
                case 'down'
                    candidatenodes=find(hObj.YData<ycurr);
                end

                if~isempty(candidatenodes)
                    currPoint=[xcurr,ycurr,zcurr];
                    candidatePoints=[hObj.XData(candidatenodes).',hObj.YData(candidatenodes).',hObj.ZData(candidatenodes).'];
                    distSqr=sum((candidatePoints-currPoint).^2,2);
                    [~,index]=min(distSqr);
                    index=candidatenodes(index);
                end
            end

            interpolationFactor=0;
        end

        function point=doGetDisplayAnchorPoint(hObj,index,~)
            point=matlab.graphics.shape.internal.util.SimplePoint(...
            [hObj.XData(index),hObj.YData(index),hObj.ZData(index)]);
        end

        function point=doGetReportedPosition(hObj,index,interpolationFactor)
            point=doGetDisplayAnchorPoint(hObj,index,interpolationFactor);
        end
    end

    methods(Access=private)


        function inputs=extractInputNameValue(hObj,inputs,name,propname)
            index=(find(strcmp(inputs(1:2:end),name))-1)*2+1;


            if nargin<=3
                propname=name;
            end
            for i=1:length(index)


                set(hObj,propname,inputs{index(i)+1});
            end
            inputs([index,index+1])=[];
        end

        [edgeCoords,edgeCoordsIndex,edgeCoordsIndexTemp]=updateEdgeCoords(hObj)

        layoutcircle(hObj,varargin)
        layoutforce(hObj,varargin)
        layoutforce3(hObj,varargin)
        layoutlayered(hObj,varargin)
        layoutsubspace(hObj,varargin)
        layoutsubspace3(hObj,varargin)

        function refreshHandles(hObj,hname)


            handles=get(hObj,hname);
            if~isempty(handles)
                numhandles=length(handles);

                newhandles=reshape(copy(handles),size(handles));
                for i=1:numhandles
                    delete(handles(i));
                end
                set(hObj,hname,newhandles);
            end
        end

        function updateMarkerHandles(hObj)
            markersize=hObj.MarkerSize;
            if isscalar(markersize)
                msi=ones(1,numnodes(hObj.BasicGraph_));
                uniquemarkersize=markersize;
            else
                [uniquemarkersize,~,msi]=unique(markersize);
            end
            marker=hObj.Marker;
            if ischar(marker)||isscalar(marker)
                mi=ones(1,numnodes(hObj.BasicGraph_));
                uniquemarker=cellstr(marker);
            else
                [uniquemarker,~,mi]=unique(marker);
            end
            [rows,~,index]=unique([msi(:),mi(:)],'rows');
            numhandles=max(index);
            numhandles_old=length(hObj.MarkerHandles_);

            for i=1:numhandles_old
                delete(hObj.MarkerHandles_(i));
            end
            nmhs=matlab.graphics.primitive.world.Marker.empty;
            for i=numhandles:-1:1
                nmhs(i)=matlab.graphics.primitive.world.Marker('Internal',true);
                set(nmhs(i),'Size',uniquemarkersize(rows(i,1)));
                hgfilter('MarkerStyleToPrimMarkerStyle',...
                nmhs(i),uniquemarker{rows(i,2)});
            end
            hObj.MarkerHandles_=nmhs;
            hObj.MarkerHandlesArrayIndex_=index;


            refreshHandles(hObj,'NodeLabelHandles_');
            refreshHandles(hObj,'EdgeLabelHandles_');
        end

        function updateEdgeLineHandles(hObj)
            linewidth=hObj.LineWidth;
            if isscalar(linewidth)
                lwi=ones(1,numedges(hObj.BasicGraph_));
                uniquelinewidth=linewidth;
            else
                [uniquelinewidth,~,lwi]=unique(linewidth);
            end
            linestyle=hObj.LineStyle;
            if ischar(linestyle)||isscalar(linestyle)
                lsi=ones(1,numedges(hObj.BasicGraph_));
                uniquelinestyle=cellstr(linestyle);
            else
                [uniquelinestyle,~,lsi]=unique(linestyle);
            end

            [rows,~,index]=unique([lwi(:),lsi(:)],'rows');
            numhandles=max(index);
            numhandles_old=length(hObj.EdgeLineHandles_);

            for i=1:numhandles_old
                delete(hObj.EdgeLineHandles_(i));
            end
            elhs=matlab.graphics.primitive.world.LineStrip.empty;
            for i=numhandles:-1:1
                elhs(i)=matlab.graphics.primitive.world.LineStrip('Internal',true);
                set(elhs(i),'LineWidth',uniquelinewidth(rows(i,1)));
                hgfilter('LineStyleToPrimLineStyle',...
                elhs(i),uniquelinestyle{rows(i,2)});
            end
            hObj.EdgeLineHandles_=elhs;
            hObj.EdgeLineHandlesArrayIndex_=index;


            refreshHandles(hObj,'MarkerHandles_');
            refreshHandles(hObj,'NodeLabelHandles_');
            refreshHandles(hObj,'EdgeLabelHandles_');
        end

        function updateNodeLabelHandles(hObj)

            fontSize=hObj.isNodeFontBold_I;
            if isscalar(fontSize)
                boldInd=ones(1,numnodes(hObj.BasicGraph_));
                uniqueIsBold=fontSize;
            else
                [uniqueIsBold,~,boldInd]=unique(fontSize);
            end
            isItalic=hObj.isNodeFontItalic_I;
            if isscalar(isItalic)
                italicInd=ones(1,numnodes(hObj.BasicGraph_));
                uniqueIsItalic=isItalic;
            else
                [uniqueIsItalic,~,italicInd]=unique(isItalic);
            end
            fontColor=hObj.NodeLabelColor_I;
            if isrow(fontColor)
                colorInd=ones(1,numnodes(hObj.BasicGraph_));
                uniqueColor=fontColor;
            else
                [uniqueColor,~,colorInd]=unique(fontColor,'rows');
            end
            fontSize=hObj.NodeFontSize_I;
            if isscalar(fontSize)
                sizeInd=ones(1,numnodes(hObj.BasicGraph_));
                uniqueSize=fontSize;
            else
                [uniqueSize,~,sizeInd]=unique(fontSize);
            end

            if hObj.Layout_~="circle"
                [rows,~,index]=unique([boldInd(:),italicInd(:),colorInd(:),sizeInd(:)],'rows');
            else


                rows=[boldInd(:),italicInd(:),colorInd(:),sizeInd(:)];
                index=(1:numnodes(hObj.BasicGraph_))';
            end

            nlhs=hObj.NodeLabelHandles_;
            nrLabels=max(index);
            nrHandles=numel(nlhs);


            if nrLabels~=nrHandles
                for i=1:nrHandles
                    delete(nlhs(i));
                end
                nlhs=matlab.graphics.primitive.world.Text.empty;
                for i=nrLabels:-1:1
                    nodeLabel=matlab.graphics.primitive.world.Text('Internal',true);
                    nlhs(i)=nodeLabel;
                end
                hObj.NodeLabelHandles_=nlhs;
            end

            for i=nrLabels:-1:1
                nodeLabel=nlhs(i);
                isBold=uniqueIsBold(rows(i,1));
                if isBold
                    nodeLabel.Font.Weight='bold';
                else
                    nodeLabel.Font.Weight='normal';
                end

                isItalic=uniqueIsItalic(rows(i,2));
                if isItalic
                    nodeLabel.Font.Angle='italic';
                else
                    nodeLabel.Font.Angle='normal';
                end

                col=uniqueColor(rows(i,3),:);
                set(nodeLabel,'Color',uint8([255*col,255]'));

                nodeLabel.Font.Size=uniqueSize(rows(i,4));
            end
            hObj.NodeLabelHandlesArrayIndex_=index;
            refreshHandles(hObj,'EdgeLabelHandles_');
        end

        function updateEdgeLabelHandles(hObj)
            nehs=hObj.EdgeLabelHandles_;
            nrLabels=sum(~cellfun(@isempty,hObj.EdgeLabel_I));
            nrHandles=numel(nehs);

            if nrLabels~=nrHandles
                for i=1:nrHandles
                    delete(nehs(i));
                end
                nehs=matlab.graphics.primitive.world.Text.empty;
                for i=nrLabels:-1:1
                    edgeLabel=matlab.graphics.primitive.world.Text('Internal',true);
                    edgeLabel.Font.Size=8;
                    edgeLabel.Font.Name='Helvetica';
                    edgeLabel.Font.Angle='italic';
                    nehs(i)=edgeLabel;
                end
                hObj.EdgeLabelHandles_=nehs;
            end
        end

        function setData(hObj,newXData,newYData,newZData)


            hObj.XData_I=reshape(newXData,1,[]);
            hObj.YData_I=reshape(newYData,1,[]);

            if nargin>3
                hObj.ZData_I=reshape(newZData,1,[]);
            else
                hObj.ZData_I=zeros(size(hObj.XData_I));
            end

            [hObj.EdgeCoords_,hObj.EdgeCoordsIndex_]=updateEdgeCoords(hObj);
            hObj.MarkDirty('all');
            hObj.sendDataChangedEvent();
        end

    end




    properties(Access='private')














        CompatibilityHelper=struct;

    end
    properties(Constant,Access='private')






        version=2.0;
    end

    methods(Static,Hidden)
        function varargout=doloadobj(hObj)
            if isfield(hObj.CompatibilityHelper,'versionSavedFrom')
                if matlab.graphics.chart.primitive.GraphPlot.version<...
                    hObj.CompatibilityHelper.minCompatibleVersion
                    warning(message('MATLAB:graphfun:plot:IncompatibleVersion'));
                    hObj=matlab.graphics.chart.primitive.GraphPlot;
                elseif isfield(hObj.CompatibilityHelper,'SaveMultiGraph')
                    s=hObj.CompatibilityHelper.SaveMultiGraph;
                    hObj=matlab.graphics.chart.primitive.GraphPlot;
                    props=intersect(fieldnames(s),definingPropertiesOfGraphPlot());
                    for p=props(:)'
                        hObj.(p)=s.(p);
                    end
                end
            end


            if~isempty(hObj.BasicGraph_)
                updateEdgeLineHandles(hObj);
                updateEdgeLabelHandles(hObj)
                hObj.EdgeArrowHandles_=matlab.graphics.primitive.world.TriangleStrip('Internal',true);
                updateMarkerHandles(hObj);
                updateNodeLabelHandles(hObj)
            end
            varargout{1}=hObj;
        end
    end

    methods(Hidden)
        function hObjOut=saveobj(hObj)

            if ismultigraph(hObj.BasicGraph_)


                hObjOut=matlab.graphics.chart.primitive.GraphPlot;


                hObjOut.CompatibilityHelper.WarnIfLoadingPreR2018a=matlab.internal.graph.Graph_with_multiple_edges_not_supported_prior_to_release_2018a;



                props=definingPropertiesOfGraphPlot();
                s=struct;
                for p=props
                    s.(p)=hObj.(p);
                end

                hObjOut.CompatibilityHelper.SaveMultiGraph=s;
            else
                hObjOut=hObj;
            end

            hObjOut.CompatibilityHelper.versionSavedFrom=matlab.graphics.chart.primitive.GraphPlot.version;
            hObjOut.CompatibilityHelper.minCompatibleVersion=2.0;
        end
    end

    methods(Static,Access=private)

        function labels=num2labels(x)
            str=num2str(reshape(x,1,[]));
            labels=textscan([str,' '],'%s');
            labels=reshape(labels{1},1,[]);
        end

        function index=moveDataCursorToSibling(xdata,ydata,xcurr,ycurr,index)


            lsiblings=find(ydata==ycurr&xdata<xcurr);
            if~isempty(lsiblings)
                [~,lsibindex]=min(xcurr-xdata(lsiblings));
                index=lsiblings(lsibindex);
            end
        end

        function index=moveDataCursorToNextLayer(xdata,ydata,xcurr,ycurr,index)


            nlayers=find(ydata<ycurr);
            if~isempty(nlayers)
                ydiff=ycurr-ydata(nlayers);

                nlayernext=nlayers(ydiff==min(ydiff));
                [~,index]=min(abs(xdata(nlayernext)-xcurr));
                index=nlayernext(index);
            end
        end
    end
    methods(Access=private)
        function index=localGetNearestPoint(hObj,position,isPixelPosition)
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();

            if strcmp(hObj.Layout_,'layered')


                dir=findparamvalue(hObj.LayoutParameters_,...
                'Direction','down');
                switch dir
                case{'down','up'}
                    yindex=pickUtils.nearestPoint(hObj,position,isPixelPosition,...
                    hObj.XData,hObj.YData,'y');
                    yindex=find(hObj.YData==hObj.YData(yindex));
                    ynearestlayer=hObj.YData(yindex);
                    xnearestlayer=hObj.XData(yindex);
                    xindex=pickUtils.nearestPoint(hObj,position,isPixelPosition,...
                    xnearestlayer,ynearestlayer,'x');
                    index=yindex(xindex);
                case{'left','right'}
                    xindex=pickUtils.nearestPoint(hObj,position,isPixelPosition,...
                    hObj.XData,hObj.YData,'x');
                    xindex=find(hObj.XData==hObj.XData(xindex));
                    xnearestlayer=hObj.XData(xindex);
                    ynearestlayer=hObj.YData(xindex);
                    yindex=pickUtils.nearestPoint(hObj,position,isPixelPosition,...
                    xnearestlayer,ynearestlayer,'y');
                    index=xindex(yindex);
                end
            else


                index=pickUtils.nearestPoint(hObj,position,isPixelPosition,...
                hObj.XData,hObj.YData,hObj.ZData);
            end
        end
    end
end

function v=findparamvalue(paramlist,paramname,defaultv)
    v=defaultv;

    [~,paramindex]=ismember(paramname,paramlist(end-1:-2:1));
    if paramindex>0
        v=paramlist{end-2*paramindex+2};
    end
end
function props=definingPropertiesOfGraphPlot()
    mco=?matlab.graphics.chart.primitive.GraphPlot;
    pList=mco.PropertyList;
    props=string.empty;
    for ii=1:numel(pList)
        p=pList(ii);
        if isequal(p.DefiningClass,mco)&&~p.Transient&&~p.Dependent&&~p.Constant
            props(end+1)=string(p.Name);%#ok<AGROW>
        end
    end
end

function mustBe_matlab_mixin_Heterogeneous(input)
    if~isa(input,'matlab.mixin.Heterogeneous')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropInitialClsMismatch','%s',message('MATLAB:type:PropInitialClsMismatch','matlab.mixin.Heterogeneous').getString));
    end
end
