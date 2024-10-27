import {fail} from '@sveltejs/kit';

/** @type {import('./$types').Actions} */
export const actions =  {
    login : async ({request,fetch, cookies}) => {
        try{
            const formData = await request.formData();
            const email = formData.get('email');
            const password = formData.get('password');
        

        const response = await fetch(import.meta.env.VITE_BACKEND_URL + '/api/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                email,
                password
            })
        });
        
        const result = await response.json();

        if(!response.ok){
            return fail(response.status,{
                success: false,
                message: result.message || 'Something went wrong',
                errors: result.errors || [],
                values: {email, password}
            });
        }

        cookies.set('token', result.data.token,{
            httpOnly: true,
            path: '/',
            maxAge: 60 * 60
        });
        cookies.set('user', JSON.stringify(result.data.user),{
            httpOnly: true,
            path: '/',
            maxAge: 60 * 60
        });
        
        return {
            success: true,
            message: result.message || 'User created successfully'
        }

    } catch (error) {
        console.error('Error', error);
        return fail(500, {
            success: false,
            message: 'Something went wrong'
        });
    }

    }
}