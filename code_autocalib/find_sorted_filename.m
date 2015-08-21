function [filenames,inds] = find_sorted_filename(datadir, prefix, suffix)
% Find all files beginning with prefix and ending with suffix in datadir;
% Sort these files by digits(digits in file names are assumed).

files = dir([datadir filesep [prefix '*' suffix]]);

fileindex = zeros(length(files),1);
filenames = {};
for i = 1:length(files)
    [matchstart, matchend] = regexp(files(i).name, '([^\d]|^)\d+([^\d]|$)');
    % Update: handle the case when first/last character is a number
    if ~isempty(matchstart)
        hi = matchstart(end);
        ti = matchend(end);
        head = files(i).name(hi);
        tail = files(i).name(ti);
        if '0' <= head && head <= '9';  hi = hi - 1; end
        if '0' <= tail && tail <= '9';  ti = ti + 1; end
        fileindex(i) = str2num(files(i).name(hi+1:ti-1));
        filenames{i} = [datadir filesep files(i).name];
    else
        % Update: handles the case when there is not number in the filename
        fileindex(i) = -1;
        filenames{i} = [datadir filesep files(i).name];
    end
end

[tmp,sortedIndex] = sort(fileindex) ;

filenames = filenames(sortedIndex);

if nargout == 2
    inds = fileindex(sortedIndex);
end
