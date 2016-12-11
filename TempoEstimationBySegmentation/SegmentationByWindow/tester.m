fileName = 'test_window_improved.m';
mlintID = 'NOPTS';                       %# The ID of the warning
mlintData = mlint(fileName,'-id');       %# Run mlint on the file
index = strcmp({mlintData.id},mlintID);  %# Find occurrences of the warnings...
lineNumbers = [mlintData(index).line]   %#   ... and their line numbers

