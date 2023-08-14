classdef Parameters















































%#ok<*MCSUP>


    properties(Dependent=true)
NumSocPoints
NumRC
NumTimeConst
    end
    properties
        SOC=1

        Em=4
        EmMin=0.1
        EmMax=5

        R0=.05
        R0Min=.0001
        R0Max=1

        Rx=.001
        RxMin=.0001
        RxMax=1

        Tx=100
        TxMin=0.1
        TxMax=10000
    end



    methods
        function obj=Parameters(NumSocPoints,NumRC,RCBranchesUse2TimeConstants)

            if nargin<3
                RCBranchesUse2TimeConstants=false;
                if nargin<2
                    NumRC=3;
                    if nargin<1
                        NumSocPoints=11;
                    end
                end
            end

            obj.SOC=0:1/(NumSocPoints-1):1;

            obj.Em=repmat(obj.Em,[1,NumSocPoints]);
            obj.EmMin=repmat(obj.EmMin,[1,NumSocPoints]);
            obj.EmMax=repmat(obj.EmMax,[1,NumSocPoints]);

            obj.R0=repmat(obj.R0,[1,NumSocPoints]);
            obj.R0Min=repmat(obj.R0Min,[1,NumSocPoints]);
            obj.R0Max=repmat(obj.R0Max,[1,NumSocPoints]);

            obj.Rx=repmat(obj.Rx,[NumRC,NumSocPoints]);
            obj.RxMin=repmat(obj.RxMin,[NumRC,NumSocPoints]);
            obj.RxMax=repmat(obj.RxMax,[NumRC,NumSocPoints]);

            if RCBranchesUse2TimeConstants
                obj.Tx=repmat(obj.Tx,[NumRC,NumSocPoints,2]);
                obj.TxMin=repmat(obj.TxMin,[NumRC,NumSocPoints,2]);
                obj.TxMax=repmat(obj.TxMax,[NumRC,NumSocPoints,2]);
            else
                obj.Tx=repmat(obj.Tx,[NumRC,NumSocPoints]);
                obj.TxMin=repmat(obj.TxMin,[NumRC,NumSocPoints]);
                obj.TxMax=repmat(obj.TxMax,[NumRC,NumSocPoints]);
            end
        end
    end





    methods
        function value=get.NumSocPoints(obj)
            value=numel(obj.SOC);
        end
        function value=get.NumRC(obj)
            value=size(obj.Tx,1);
        end
        function value=get.NumTimeConst(obj)
            value=size(obj.Tx,3);
        end
    end



    methods

        function obj=set.Em(obj,value)
            if~isscalar(obj.EmMin)&&~isscalar(obj.EmMax)
                validateattributes(value,{'numeric'},{'vector','size',size(obj.EmMin),'positive','finite'});
                idxBad=value>obj.EmMax;
                if any(idxBad)
                    warning(getString(message('autoblks:autoblkErrorMsg:errEmH')))
                    obj.EmMax(idxBad)=value(idxBad)+1e-6;
                end
                idxBad=value<obj.EmMin;
                if any(idxBad)
                    warning(getString(message('autoblks:autoblkErrorMsg:errEmL')))
                    obj.EmMin(idxBad)=value(idxBad)-1e-6;
                end
            end
            obj.Em=value;
        end

        function obj=set.EmMin(obj,value)
            validateattributes(value,{'numeric'},{'vector','size',size(obj.Em),'positive','finite'});
            if~isscalar(obj.EmMin)&&~isscalar(obj.EmMax)
                idxBad=value>obj.EmMax;
                if any(idxBad)
                    warning(getString(message('autoblks:autoblkErrorMsg:errSetH')))
                    obj.EmMax(idxBad)=value(idxBad)+1e-6;
                end
            end
            obj.EmMin=value;
        end

        function obj=set.EmMax(obj,value)
            validateattributes(value,{'numeric'},{'vector','size',size(obj.Em),'positive','finite'});
            if~isscalar(obj.EmMin)&&~isscalar(obj.EmMax)
                idxBad=value<obj.EmMin;
                if any(idxBad)
                    warning(getString(message('autoblks:autoblkErrorMsg:errSetL')))
                    obj.EmMin(idxBad)=value(idxBad)+1e-6;
                end
            end
            obj.EmMax=value;
        end


        function obj=set.R0(obj,value)
            if~isscalar(obj.R0Min)&&~isscalar(obj.R0Max)
                validateattributes(value,{'numeric'},{'vector','size',size(obj.R0Min),'positive','finite'});
                idxBad=value>obj.R0Max;
                if any(idxBad)
                    warning(getString(message('autoblks:autoblkErrorMsg:errROH')))
                    obj.R0Max(idxBad)=value(idxBad)+1e-6;
                end
                idxBad=value<obj.R0Min;
                if any(idxBad)
                    warning(getString(message('autoblks:autoblkErrorMsg:errROL')))
                    obj.R0Min(idxBad)=value(idxBad)-1e-6;
                end
            end
            obj.R0=value;
        end

        function obj=set.R0Min(obj,value)
            validateattributes(value,{'numeric'},{'vector','size',size(obj.R0),'positive','finite'});
            if~isscalar(obj.R0Min)&&~isscalar(obj.R0Max)
                idxBad=value>obj.R0Max;
                if any(idxBad)
                    warning(getString(message('autoblks:autoblkErrorMsg:errROmin')))
                    obj.R0Max(idxBad)=value(idxBad)+1e-6;
                end
            end
            obj.R0Min=value;
        end

        function obj=set.R0Max(obj,value)
            validateattributes(value,{'numeric'},{'vector','size',size(obj.R0),'positive','finite'});
            if~isscalar(obj.R0Min)&&~isscalar(obj.R0Max)
                idxBad=value<obj.R0Min;
                if any(idxBad)
                    warning(getString(message('autoblks:autoblkErrorMsg:errROmax')))
                    obj.R0Min(idxBad)=value(idxBad)+1e-6;
                end
            end
            obj.R0Max=value;
        end


        function obj=set.Rx(obj,value)
            if~isscalar(obj.RxMin)&&~isscalar(obj.RxMax)
                validateattributes(value,{'numeric'},{'2d','size',size(obj.RxMin),'positive','finite'});
                idxBad=value>obj.RxMax;
                if any(idxBad(:))
                    warning(getString(message('autoblks:autoblkErrorMsg:errRxH')))
                    obj.RxMax(idxBad)=value(idxBad)+1e-6;
                end
                idxBad=value<obj.RxMin;
                if any(idxBad(:))
                    warning(getString(message('autoblks:autoblkErrorMsg:errRxL')))
                    obj.RxMin(idxBad)=value(idxBad)-1e-6;
                end
            end
            obj.Rx=value;
        end

        function obj=set.RxMin(obj,value)
            validateattributes(value,{'numeric'},{'2d','size',size(obj.Rx),'positive','finite'});
            if~isscalar(obj.RxMin)&&~isscalar(obj.RxMax)
                idxBad=value>obj.RxMax;
                if any(idxBad(:))
                    warning(getString(message('autoblks:autoblkErrorMsg:errRxMin')))
                    obj.RxMax(idxBad)=value(idxBad)+1e-6;
                end
            end
            obj.RxMin=value;
        end

        function obj=set.RxMax(obj,value)
            validateattributes(value,{'numeric'},{'2d','size',size(obj.Rx),'positive','finite'});
            if~isscalar(obj.RxMin)&&~isscalar(obj.RxMax)
                idxBad=value<obj.RxMin;
                if any(idxBad(:))
                    warning(getString(message('autoblks:autoblkErrorMsg:errRxMax')))
                    obj.RxMin(idxBad)=value(idxBad)+1e-6;
                end
            end
            obj.RxMax=value;
        end


        function obj=set.Tx(obj,value)
            if~isscalar(obj.TxMin)&&~isscalar(obj.TxMax)
                validateattributes(value,{'numeric'},{'3d','size',size(obj.TxMin),'positive','finite'});
                idxBad=value>obj.TxMax;
                if any(idxBad(:))
                    warning(getString(message('autoblks:autoblkErrorMsg:errTxH')))
                    obj.TxMax(idxBad)=value(idxBad)+1e-6;
                end
                idxBad=value<obj.TxMin;
                if any(idxBad(:))
                    warning(getString(message('autoblks:autoblkErrorMsg:errTxL')))
                    obj.TxMin(idxBad)=value(idxBad)-1e-6;
                end
            end
            obj.Tx=value;
        end

        function obj=set.TxMin(obj,value)

            if~isscalar(obj.TxMin)&&~isscalar(obj.TxMax)
                validateattributes(value,{'numeric'},{'3d','size',size(obj.Tx),'positive','finite'});
                idxBad=value>obj.TxMax;
                if any(idxBad(:))
                    warning(getString(message('autoblks:autoblkErrorMsg:errTxMin')))
                    obj.TxMax(idxBad)=value(idxBad)+1e-6;
                end
            end
            obj.TxMin=value;
        end

        function obj=set.TxMax(obj,value)

            if~isscalar(obj.TxMin)&&~isscalar(obj.TxMax)
                validateattributes(value,{'numeric'},{'3d','size',size(obj.Tx),'positive','finite'});
                idxBad=value<obj.TxMin;
                if any(idxBad(:))
                    warning(getString(message('autoblks:autoblkErrorMsg:errTxMax')))
                    obj.TxMin(idxBad)=value(idxBad)+1e-6;
                end
            end
            obj.TxMax=value;
        end


    end


end