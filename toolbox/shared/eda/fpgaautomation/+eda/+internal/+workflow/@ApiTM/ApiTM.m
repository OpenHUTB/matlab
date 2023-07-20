classdef ApiTM<handle







    properties(SetAccess=public,GetAccess=public,Hidden=true)
    end




    properties(SetAccess=protected,GetAccess=protected,Hidden=true)

    end




    methods(Access='public')


        function h=ApiTM(varargin)
        end

        function found=isApiInstalled(h)
            x=which('xilinx.environment.getiseversion');
            found=~isempty(x);
        end

        function ver=getIseVersion(h)
            ver=xilinx.environment.getiseversion;
        end

        function ver=getApiVersion(h)
            ver=xilinx.environment.getapiversion;
        end


        function parts=getPartInfo(h,varargin)
            parts={};

            if nargin==1

                parts=xilinx.environment.getpartinfo('all');
            end

            if nargin==2

                parts=xilinx.environment.getpartinfo(varargin{1},'all');
            end

            if nargin==3&&strcmpi(varargin{2},'name')


                parts=xilinx.environment.getpartinfo(...
                varargin{1},'CustomerPartName');
            end

            if nargin==4
                if strcmpi(varargin{3},'speed')

                    parts=xilinx.environment.getpartinfo(...
                    varargin{1},varargin{2},'spds','all');

                elseif strcmpi(varargin{3},'package')

                    parts=xilinx.environment.getpartinfo(...
                    varargin{1},varargin{2},'pkgs','all');
                end
            end
        end

        function families=getSupportedFamiliesForClock(h)
            families=xilinx.clocking.supportedfamilies;
        end

        function[success,errMsg]=checkClock(h,params)
            [success,errMsg]=xilinx.clocking.check(params);
        end

        function clkModule=generateClock(h,params)
            clkModule=xilinx.clocking.generate(params);
        end


    end

end