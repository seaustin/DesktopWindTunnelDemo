files = ls('*.dat');
files = strsplit(files);
files(end) = [];
commentMatch = 'User comment: (\S*)';


for i = 1:length(files)
    fname(i) = string(files(i));
    contents = fileread(fname(i));
    comment(i) = string(regexp(contents, commentMatch, 'tokens'));
end

[commentSorted, sortIdx] = sort(comment, 'descend');

jointArray = [fname(sortIdx)', commentSorted']