
function ITensor(::Type{ElT},
                 flux::QN,
                 inds::IndexSet) where {ElT<:Number}
  blocks = nzblocks(flux,inds)
  T = BlockSparseTensor(ElT,blocks,inds)
  return itensor(T)
end

function ITensor(inds::QNIndex...)
  T = BlockSparseTensor(IndexSet(inds))
  return itensor(T)
end

function ITensor(::Type{ELT},inds::QNIndex...) where {ELT<:Number} 
  T = BlockSparseTensor(ELT,inds)
  return itensor(T)
end

ITensor(::Type{T},
        flux::QN,
        inds::Index...) where {T<:Number} = ITensor(T,flux,IndexSet(inds...))


ITensor(flux::QN,inds::IndexSet) = ITensor(Float64,flux::QN,inds...)

ITensor(flux::QN,
        inds::Index...) = ITensor(flux,IndexSet(inds...))

function randomITensor(::Type{ElT},
                       flux::QN,
                       inds::IndexSet) where {ElT<:Number}
  T = ITensor(ElT,flux,inds)
  randn!(T)
  return T
end

function randomITensor(::Type{T},
                       flux::QN,
                       inds::Index...) where {T<:Number}
  return randomITensor(T,flux,IndexSet(inds...))
end

randomITensor(flux::QN,inds::IndexSet) = randomITensor(Float64,flux::QN,inds...)

randomITensor(flux::QN,
              inds::Index...) = randomITensor(flux,IndexSet(inds...))

# Throw error if flux is not specified
randomITensor(::Type{T},
              inds::QNIndex...) where {T<:Number} = error("In randomITensor constructor, must specify desired flux when using QN Indices")

randomITensor(inds::QNIndex...) = randomITensor(Float64,inds...)

function combiner(inds::QNIndex...; kwargs...)
  # TODO: support combining multiple set of indices
  tags = get(kwargs, :tags, "CMB,Link")
  new_ind = ⊗(inds...)
  if all(i->dir(i)!=Out,inds) && all(i->dir(i)!=In,inds)
    new_ind = dag(new_ind)
    new_ind = replaceqns(new_ind,-qnblocks(new_ind))
  end
  new_ind = settags(new_ind,tags)
  comb_ind,perm,comb = combineblocks(new_ind)
  return ITensor(Combiner(perm,comb),IndexSet(comb_ind,dag.(inds)...)),comb_ind
end
combiner(inds::Tuple{Vararg{QNIndex}}; kwargs...) = combiner(inds...; kwargs...)

function replaceindex!(A::ITensor,i::QNIndex,j::QNIndex)
  space(i) != space(j) && error("Indices must have the same spaces to be replaced")
  pos = indexpositions(A,i)
  isempty(pos) && error("Index not found")
  curdir = dir(inds(A)[pos[1]])
  inds(A)[pos[1]] = setdir(j,curdir)
  return A
end