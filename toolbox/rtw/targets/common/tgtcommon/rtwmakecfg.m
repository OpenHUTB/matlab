function makeInfo=rtwmakecfg()
%RTWMAKECFG adds include and source directories to the generated makefiles.
%   For details refer to the documentation on the rtwmakecfg API.

%   Copyright 1996-2021 The MathWorks, Inc.

disp('### Driver Interface Libraries');

root = bdroot;
% @todo update the usage of edit-time filter filterOutInactiveVariantSubsystemChoices()
% instead use the post-compile filter activeVariants() - g2597518
blocks = find_system(root,...
		     'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,... % look only inside active choice of VSS
		     'RegExp', 'on', ...
		     'ReferenceBlock', '\<driver_interface_library/Input Driver\>|\<driver_interface_library/Output Driver\>' );

% initialize
makeInfo.includePath = { };
makeInfo.sourcePath = { };
makeInfo.sources = { };

for i1 = 1:length(blocks)
  block = blocks{i1};
  if ~isempty(block)
    addheader(get_param(block,'header'));
    addsrc(get_param(block,'src'));
  end
end

  function addheader(header)
    PATHSTR = fileparts(header);
    PATHSTR = expand(PATHSTR);
    paths = makeInfo.includePath;
    if ~isempty(PATHSTR)
      paths = { paths{:} PATHSTR }; %#ok
      makeInfo.includePath = paths;
    end
  end

  function addsrc(src)
    PATHSTR = fileparts(src);
    PATHSTR = expand(PATHSTR);
    paths = makeInfo.sourcePath;
    if ~isempty(PATHSTR)
      paths = { paths{:} PATHSTR }; %#ok
      makeInfo.sourcePath = paths;
    end
  end

  function path = expand(path)
    expansions = regexp(path,'(\$[^\\/]*)','tokens');
    for i = 1:length(expansions)
      ex = expansions{i}{1};
      fun = strrep(ex,'$','');
      str = feval(fun);
      path = strrep(path,ex,str);
    end
  end

end
