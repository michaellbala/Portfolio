import {faile} from '@sveltejs/kit';

/** @type {import('./$types').Actions} */
export const actions =  {
    create: async ({request, cookies}) => {
        try {
        const token = cookies.get('token');

        const formData = await request.formData();
        const name = formData.get('name');
        const email = formData.get('email');
        const password = formData.get('password');

        const response = await fetch(import.meta.env.VITE_BACKEND_URL + '/api/admin/users', {
        method: 'POST',
        headers: {
            'Authorization': `${token}`,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            name,
            email,
            password
        })
        });

        const result = await response.json();
        if (!response.ok) {
        return fail(response.status, {
            success: false,
            message: result.message || 'Something went wrong',
            errors: result.errors || [],
            values: { name, email }
        });
    }

    return {
        success: true,
        message: 'User created successfully',
    };

    } catch (error) {
    if (error instanceof Response) {
    throw error;
    }
    console.error('Error', error);
    return fail(500, { 
        success: false, 
        message: 'Something went wrong' });
    }


    }
}