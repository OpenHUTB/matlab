function m_removeCursors(p,cursorIndex)







    if nargin>1
        removeCursors(p,cursorIndex);
    else
        removeAllCursors(p,'all');
    end
