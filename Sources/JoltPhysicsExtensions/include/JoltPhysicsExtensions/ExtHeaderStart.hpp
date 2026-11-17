//
//  ExtHeaderStart.hpp
//  JoltPhysics
//
//  Created by Evgenij Lutz on 17.11.26.
//

#pragma once

#if !defined NDEBUG
# define undef_NDEBUG // undef NDEBUG at the end of the file
# define NDEBUG
#endif

#if !defined JPH_OBJECT_STREAM
# define JPH_OBJECT_STREAM
#endif

// The library was compiled with this flag (build_framework.sh)
#define JPH_USE_MTL 1
