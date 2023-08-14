classdef CustomSnapshot<handle














    properties
        Width(1,1)double{mustBePositive}=600;
        Height(1,1)double{mustBePositive}=400;

        Rows(1,1)double{mustBePositive,mustBeInteger,mustBeLessThanOrEqual(Rows,8)}=1;
        Columns(1,1)double{mustBePositive,mustBeInteger,mustBeLessThanOrEqual(Columns,8)}=1;

        TimeSpan double{Simulink.sdi.CustomSnapshot.mustBeValidRange}=[]
        YRange cell={}
    end


    methods

        function obj=CustomSnapshot()
            obj.OffscreenUI=Simulink.sdi.Instance.offscreenBrowser();
            clearSignals(obj);
            resizePlotProps(obj);
        end

        function set.Rows(this,val)
            this.Rows=val;
            resizePlotProps(this);
        end

        function set.Columns(this,val)
            this.Columns=val;
            resizePlotProps(this);
        end

        function set.YRange(this,val)
            validateYRange(this,val);
            this.YRange=val;
        end

        [hFig,img_data]=snapshot(this,varargin)
        plotOnSubPlot(this,row,col,signal,bPlot)
        plotComparison(this,dsr)
        clearSignals(this)
    end


    methods(Hidden)
        resizePlotProps(this)
        validateYRange(this,val)
        updateClient(this)
        ret=getClient(this,bComparison)
    end

    methods(Hidden,Static)
        mustBeValidRange(val)
    end


    properties(Access='private')
OffscreenUI
Signals
ComparisonSignalID
    end
end
