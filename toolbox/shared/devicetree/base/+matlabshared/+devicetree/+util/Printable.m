classdef Printable<handle


    methods
        function obj=Printable
        end
    end


    methods(Sealed)
        function printSource(obj,varargin)




            if nargin<2

                isDTSI=false;
            else

                fileName=varargin{1};
                [~,~,ext]=fileparts(fileName);
                isDTS=strcmp(ext,".dts");
                isDTSI=strcmp(ext,".dtsi");
                if~(isDTS||isDTSI)
                    error('File extension must be ".dts" or ".dtsi".');
                end
            end


            isOverlay=false;
            isIncludeFile=isDTSI;
            obj.print(isOverlay,isIncludeFile,varargin{:});
        end

        function printOverlaySource(obj,varargin)




            if nargin<2

            else

                fileName=varargin{1};
                [~,~,ext]=fileparts(fileName);
                isDTS=strcmp(ext,".dts");
                isDTSO=strcmp(ext,".dtso");
                if~(isDTS||isDTSO)
                    error('File extension must be ".dts" or ".dtso".');
                end
            end


            isOverlay=true;
            isIncludeFile=false;
            obj.print(isOverlay,isIncludeFile,varargin{:});
        end
    end


    methods(Access=private)
        function print(obj,isOverlay,isIncludeFile,varargin)



            hDTPrinter=matlabshared.devicetree.util.DeviceTreePrinter();

            printObject(obj,hDTPrinter,isOverlay,isIncludeFile);



            hDTPrinter.print(varargin{:});
        end
    end

    methods(Sealed,Hidden)


        function printObject(obj,hDTPrinter,isOverlay,isIncludeFile)
            if nargin<4
                isIncludeFile=false;
            end

            if nargin<3
                isOverlay=false;
            end

            printHeader(obj,hDTPrinter,isOverlay,isIncludeFile);
            printBody(obj,hDTPrinter,isOverlay,isIncludeFile);
            printFooter(obj,hDTPrinter,isOverlay,isIncludeFile);
        end
    end


    methods(Access=protected)
        function printHeader(obj,hDTPrinter,isOverlay,isIncludeFile)%#ok<INUSD>

        end

        function printBody(obj,hDTPrinter,isOverlay,isIncludeFile)%#ok<INUSD>

        end

        function printFooter(obj,hDTPrinter,isOverlay,isIncludeFile)%#ok<INUSD>

        end
    end
end