function m_exportCursors(p)

    assignin('base','cursors',p.CursorMarkers);
    str='Exported <a href="matlab:eval(''cursors'')">cursors</a> variable to the base workspace.';
    disp(str);

    showBannerMessage(p,'Exported ''cursors'' variable to the base workspace.');
