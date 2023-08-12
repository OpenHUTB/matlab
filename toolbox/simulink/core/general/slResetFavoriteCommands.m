function backupPath = slResetFavoriteCommands(  )





fm = SLStudio.FavoriteCommands.Manager.get(  );
fm.reorderCategoriesByGalleryState(  );

prefs = fm.getPreferences(  );
fm.removeFavoritesFromQAB(  );



fm.restoreFactoryPresets(  );
backupPath = fm.backupPreferences( prefs );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp_xkkZ3.p.
% Please follow local copyright laws when handling this file.

