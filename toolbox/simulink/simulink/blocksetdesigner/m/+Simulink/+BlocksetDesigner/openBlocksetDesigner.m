
function openBlocksetDesigner(varargin)

    if nargin==1&&isequal(varargin{1},'debug')
        openingMode='debug';
    else
        openingMode='release';
    end
    blocksetDesigner=Simulink.BlocksetDesigner.BlocksetDesigner.getInstance(openingMode);
    blocksetDesigner.view();
end