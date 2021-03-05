function RGB = label2rgbSam(img, background) 

% background = 0; 

% Determine the number of regions in the label matrix.
numregion = numel(unique(img));


if isa(label,'uint8') || isa(label,'uint16') || isa(label,'uint32')
    RGB = matlab.images.internal.ind2rgb8(label, cmap);
else
    % Using label + 1 for two reasons: 1) IND2RGB and IND2RGB8 do not like
    % double arrays containing zero values, and 2)for non-double, IND2RGB would
    % cast to a double and do this.
    RGB = matlab.images.internal.ind2rgb8(double(label)+1,cmap);
end
 
%  Function: parse_inputs
%  ----------------------
function [L, Map, Zerocolor, Order, Fcnflag] = parse_inputs(varargin) 
% L         label matrix: matrix containing non-negative values.  
% Map       colormap: name of standard colormap, user-defined map, function
%           handle.
% Zerocolor RGB triple or Colorspec
% Order     keyword if specified: 'shuffle' or 'noshuffle'
% Fcnflag   flag to indicating that Map is a function


narginchk(1,4);

% set defaults
L = varargin{1};
Map = 'jet';    
Zerocolor = [1 1 1]; 
Order = 'noshuffle';
Fcnflag = 0;

% parse inputs
if nargin > 1
    Map = varargin{2};
end
if nargin > 2
    Zerocolor = varargin{3};
end
if nargin > 3
    Order = varargin{4};
end

% error checking for L
validateattributes(L,{'numeric','logical'}, ...
              {'real' '2d' 'nonsparse' 'finite' 'nonnegative' 'integer'}, ...
              mfilename,'L',1);

% error checking for Map
[fcn, fcnchk_msg] = fcnchk(Map);
if isempty(fcnchk_msg)
    Map = fcn;
    Fcnflag = 1;
else
    if isnumeric(Map)
        if ~isreal(Map) || any(Map(:) > 1) || any(Map(:) < 0) || ...
                    ~isequal(size(Map,2), 3) || size(Map,1) < 1
          error(message('images:label2rgb:invalidColormap'));
        end
    else
        error(fcnchk_msg);
    end
end    
    
% error checking for Zerocolor
if ~ischar(Zerocolor)
    % check if Zerocolor is a RGB triple
    if ~isreal(Zerocolor) || ~isequal(size(Zerocolor),[1 3]) || ...
                any(Zerocolor> 1) || any(Zerocolor < 0)
      error(message('images:label2rgb:invalidZerocolor'));
    end
else    
    [cspec, msg] = cspecchk(Zerocolor);
    if ~isempty(msg)
	%message is translated at source.
        error(message('images:label2rgb:notInColorspec', msg))
    else
        Zerocolor = cspec;
    end
end

% error checking for Order
valid_order = {'shuffle', 'noshuffle'};
idx = strncmpi(Order, valid_order,length(Order));
if ~any(idx)
    error(message('images:label2rgb:invalidEntryForOrder'))
elseif nnz(idx) > 1
    error(message('images:label2rgb:ambiguousEntryForOrder', Order))
else
    Order = valid_order{idx};
end
