## Copyright (C) 2005 Julius O. Smith III <jos@ccrma.stanford.edu>
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING. If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {[@var{z}, @var{p}, @var{k}] =} sos2zp (@var{sos})
## @deftypefnx {Function File} {[@var{z}, @var{p}, @var{k}] =} sos2zp (@var{sos}, @var{g})
## Convert series second-order sections to zeros, poles, and gains
## (pole residues).
##
## INPUTS:
## @itemize
##
## @item
## @var{sos} = matrix of series second-order sections, one per row:
## @example
## @var{sos} = [@var{B1}.' @var{A1}.'; ...; @var{BN}.' @var{AN}.']
## @end example
## where
## @code{@var{B1}.' = [b0 b1 b2] and @var{A1}.' = [1 a1 a2]} for
## section 1, etc.  The b0 entry must be nonzero for each section.
## See @code{filter} for documentation of the second-order direct-form filter
## coefficients @var{B}i and @var{A}i.
##
## @item
## @var{g} is an overall gain factor that effectively scales
## any one of the input @var{B}i vectors.
## If not given the gain is assumed to be 1.
## @end itemize
##
## RETURNED:
## @itemize
## @item
## @var{z} = column-vector containing all zeros (roots of B(z))
## @item
## @var{p} = column-vector containing all poles (roots of A(z))
## @item
## @var{k} = overall gain = @var{B}(Inf)
## @end itemize
##
## EXAMPLE:
## @example
## [z, p, k] = sos2zp ([1 0 1, 1 0 -0.81; 1 0 0, 1 0 0.49])
##   @result{} z =
##     -0 + 1i
##      0 - 1i
##      0 + 0i
##      0 + 0i
##   @result{} p =
##     -0.90000 + 0.00000i
##      0.90000 + 0.00000i
##     -0.00000 + 0.70000i
##      0.00000 - 0.70000i
##   @result{} k =  1
## @end example
##
## @seealso{zp2sos, sos2tf, tf2sos, zp2tf, tf2zp}
## @end deftypefn

function [z,p,k] = sos2zp (sos, g = 1)

  if (nargin < 1 || nargin > 2)
    print_usage;
  endif

  gains = sos(:,1); # All b0 coeffs
  k = prod(gains)*g; # pole-zero gain
  if k==0, error('sos2zp: one or more section gains is zero'); endif
  sos(:,1:3) = sos(:,1:3)./ [gains gains gains];

  [N,m] = size(sos);
  if m~=6, error('sos2zp: sos matrix should be N by 6'); endif

  z = zeros(2*N,1);
  p = zeros(2*N,1);
  for i=1:N
    ndx = [2*i-1:2*i];
    zi = roots(sos(i,1:3));
    z(ndx) = zi;
    pi = roots(sos(i,4:6));
    p(ndx) = pi;
  endfor

endfunction

%!test
%! b1t=[1 2 3]; a1t=[1 .2 .3];
%! b2t=[4 5 6]; a2t=[1 .4 .5];
%! sos=[b1t a1t; b2t a2t];
%! z = [-1-1.41421356237310i;-1+1.41421356237310i;...
%!     -0.625-1.05326872164704i;-0.625+1.05326872164704i];
%! p = [-0.2-0.678232998312527i;-0.2+0.678232998312527i;...
%!      -0.1-0.538516480713450i;-0.1+0.538516480713450i];
%! k = 4;
%! [z2,p2,k2] = sos2zp(sos,1);
%! assert({cplxpair(z2),cplxpair(p2),k2},{z,p,k},100*eps);
