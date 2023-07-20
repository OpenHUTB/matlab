function html_file=psbhelp(varargin)









    narginchk(0,1);

    if isempty(docroot)
        html_file=[matlabroot,'/toolbox/physmod/powersys/powersys/power_herr.html'];
        return;
    end

    switch nargin
    case 0
        blockHandle=gcbh;
    case 1
        customOption=varargin{1};
        if ishandle(customOption)
            blockHandle=customOption;
        else
            blockHandle='';
        end
    end

    if~isempty(blockHandle)

        if strcmp(get_param(blockHandle,'BlockType'),'PMIOPort')
            blockName='Connection Port';
        else

            blockName=get_param(getfullname(blockHandle),'MaskType');
        end
    else
        blockName=customOption;
    end

    if isempty(blockName)

        blockName='powersys_product_page';
    end

    switch blockName
    case 'Detailed Thyristor'

        blockName='Thyristor';
    case 'Discrete DC machine'

        blockName='DC machine';
    case 'Discrete Total Harmonic Distortion '

        blockName='Total Harmonic Distortion';
    case 'Discrete RMS value'

        blockName='RMS';
    case 'PSB option menu block'

        blockName='Powergui';
    case 'Machine measurements'

        blockName='Machine Measurement Demux';
    case{'Fourier analyser','Discrete Fourier'}
        blockName='Fourier';
    case{'abc to dq0 Transformation','dq0 to abc Transformation'}
        blockName='abctodq0dq0toabc';
    case{'Alpha-Beta-Zero to dq0 Transformation','dq0 to Alpha-Beta-Zero Transformation'}
        blockName='alphabetazerotodq0dq0toalphabetazero';
    case{'abc to Alpha-Beta-Zero Transformation','Alpha-Beta-Zero to abc Transformation'}
        blockName='abctoalphabetazeroalphabetazerotoabc';
    case '3-Phase VI Measurement'
        blockName='three-phase vi measurement';
    case{'3-Phase Sequence analyzer','Discrete 3-Phase Sequence Analyzer'}
        blockName='Three-Phase Sequence Analyzer';
    case 'Three-Phase Linear Transformer 12-Terminals'
        blockName='Three Phase Transformer 12 Terminals';
    case 'Synchronous Machine'
        blockType=bdroot(get_param(blockHandle,'ReferenceBlock'));
        switch blockType
        case 'spsSynchronousMachinepuFundamentalLib'
            blockName='Synchronous Machine pu Fundamental';
        case 'spsSynchronousMachinepuStandardLib'
            blockName='Synchronous Machine pu Standard';
        case 'spsSynchronousMachineSIFundamentalLib'
            blockName='Synchronous Machine SI Fundamental';
        end
    end
    html_file=[docroot,'/sps/powersys/ref/',help_name(blockName)];


    function y=help_name(x)
        if isempty(x)
            x='default';
        end
        y=lower(x);
        y(~isvalidchar(y))='';
        y=[y,'.html'];
        return

        function y=isvalidchar(x)
            y=isletter(x)|isdigit(x)|isunder(x);
            return

            function y=isdigit(x)
                y=(x>='0'&x<='9');
                return

                function y=isunder(x)
                    y=(x=='_');
                    return