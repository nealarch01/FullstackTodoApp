namespace RegexVerifier {
    export function username(username: string): boolean {
        // This regular expression matches a string that:
        // 1. Contains only alphanumeric characters, underscores, dashes, and periods
        // 2. Every period, dash, and underscore is preceded and followed by an alphanumeric character
        // 3. Must contain at least one letter (to prevent usernames like "1234567890")
        const regex = /^(?=.*[A-Za-z])[A-Za-z0-9]*(?:[._-][A-Za-z0-9]+)*$/;
        return regex.test(username);
    }

    export function email(email: string): boolean {
        const regex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/;
        return regex.test(email);
    }

    export function password(password: string): boolean {
        // This regular expression matches a string that:
        // 1. contain at least one lowercase letter (?=.*[a-z])
        // 2. contain at least one uppercase letter (?=.*[A-Z])
        // 3. contain at least one digit (?=.*[0-9])
        // 4. contain at least one special character (?=.*[!@#\$%\^&\*])
        const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%\^&\*])/;
        return regex.test(password);
    }

    export function hexColor(color: string): boolean {
		// Must match: #ff00ff for example
		const regex = /^#[0-9a-f]{6}$/
        return regex.test(color);
    }
}

export {
    RegexVerifier
}
