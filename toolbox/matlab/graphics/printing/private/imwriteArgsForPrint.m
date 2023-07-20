function imwriteArgs=imwriteArgsForPrint(pj)
























    if nargin~=1||~isa(pj,'matlab.graphics.internal.mlprintjob')
        ex=MException('MATLAB:generateimwriteargs:invalidinput',getString(message('MATLAB:uistring:imwriteargsforprint:InvalidParametersSupplied')));
        throw(ex);
    end


    imwriteArgs.map=[];
    imwriteArgs.indexedData=[];

    imwriteArgs.varargs={};


    if strcmp(pj.DriverClass,'IM')
        if strncmp(pj.Driver,'tiff',4)
            imwriteArgs.varargs{end+1}='Compression';
            if strcmp(pj.Driver,'tiffnocompression')
                imwriteArgs.varargs{end+1}='none';
            else
                imwriteArgs.varargs{end+1}='packbits';
            end

            imwriteArgs.varargs{end+1}='Description';
            imwriteArgs.varargs{end+1}='MATLAB Handle Graphics';

            imwriteArgs.varargs{end+1}='Resolution';
            dpi=LocalGetDPI(pj);
            imwriteArgs.varargs{end+1}=dpi;

        elseif strncmp(pj.Driver,'jpeg',4)

            imwriteArgs.varargs{end+1}='Quality';
            imwriteArgs.varargs{end+1}=sscanf(pj.Driver,'jpeg%d');
            if isempty(imwriteArgs.varargs{end})

                imwriteArgs.varargs{end}=75;
            end

            imwriteArgs.varargs{end+1}='Comment';
            imwriteArgs.varargs{end+1}={'MATLAB Handle Graphics';...
            'MATLAB, The MathWorks, Inc.'};

        elseif strncmp(pj.Driver,'png',3)
            imwriteArgs.varargs{end+1}='CreationTime';
            imwriteArgs.varargs{end+1}=datestr(clock,0);

            imwriteArgs.varargs{end+1}='ResolutionUnit';
            imwriteArgs.varargs{end+1}='meter';


            dpi=LocalGetDPI(pj);
            dpi=fix(dpi*100.0/2.54+0.5);

            imwriteArgs.varargs{end+1}='XResolution';
            imwriteArgs.varargs{end+1}=dpi;

            imwriteArgs.varargs{end+1}='YResolution';
            imwriteArgs.varargs{end+1}=dpi;

            imwriteArgs.varargs{end+1}='Software';
            imwriteArgs.varargs{end+1}='MATLAB, The MathWorks, Inc.';

            if~(any(strcmp(pj.Driver,{'png','png16m'})))
                switch pj.Driver(4:end)
                case 'mono'
                    numBits=1;
                    numColors=2;
                case 'gray'
                    numBits=8;
                    numColors=7;
                case '256'
                    numBits=8;
                    numColors=256;
                end

                [imwriteArgs.indexedData,imwriteArgs.map]=rgb2ind(pj.Return,colorcube(numColors));
                imwriteArgs.varargs{end+1}='bitdepth';
                imwriteArgs.varargs{end+1}=numBits;
            end

        elseif strncmp(pj.Driver,'pcx',3)


            if strcmp(pj.Driver,'pcx')
                numColors=256;
            else
                switch pj.Driver(4:end)
                case '16'
                    numColors=16;
                case '256'
                    numColors=256;
                case '24b'
                    numColors=256;
                case 'mono'
                    numColors=2;
                case 'gray'
                    numColors=7;
                end
            end

            [imwriteArgs.indexedData,imwriteArgs.map]=rgb2ind(pj.Return,colorcube(numColors));

        elseif strncmp(pj.Driver,'pbm',3)
            imwriteArgs.varargs{end+1}='Encoding';
            if strcmp(pj.Driver,'pbmraw')
                imwriteArgs.varargs{end+1}='rawbits';
            else
                imwriteArgs.varargs{end+1}='ascii';
            end


            numColors=2;
            [imwriteArgs.indexedData,imwriteArgs.map]=rgb2ind(pj.Return,colorcube(numColors));

        elseif strncmp(pj.Driver,'pgm',3)
            imwriteArgs.varargs{end+1}='Encoding';
            if strcmp(pj.Driver,'pgmraw')
                imwriteArgs.varargs{end+1}='rawbits';
            else
                imwriteArgs.varargs{end+1}='ascii';
            end

        elseif strncmp(pj.Driver,'ppm',3)
            imwriteArgs.varargs{end+1}='Encoding';
            if strcmp(pj.Driver,'ppmraw')
                imwriteArgs.varargs{end+1}='rawbits';
            else
                imwriteArgs.varargs{end+1}='ascii';
            end

        elseif strncmp(pj.Driver,'bmp',3)
            if any(strcmp(pj.Driver,{'bmp','bmp16m'}))
                numColors=0;
            else
                switch pj.Driver(4:end)
                case 'mono'
                    numColors=2;
                case '256'
                    numColors=256;
                end
            end
            if numColors>0
                [imwriteArgs.indexedData,imwriteArgs.map]=rgb2ind(pj.Return,colorcube(numColors));


                if strcmp(pj.Driver,'bmpmono')
                    imwriteArgs.indexedData=logical(imwriteArgs.indexedData);
                end
            end

        end
    end
end


function dpi=LocalGetDPI(pj)



    if pj.DPI==-1
        dpi=150;
    elseif pj.DPI==0
        dpi=get(0,'screenpixelsperinch');
    else
        dpi=pj.DPI;
    end
end
